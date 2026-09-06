'use strict';

const fs = require('fs');
const path = require('path');
const functions = require('@google-cloud/functions-framework');
const { google } = require('googleapis');

const FOLDER_ID =
  process.env.DRIVE_FOLDER_ID || '1bwuJe5xiUYW7PxqnaCJGmXngvpTt4ygz';
const API_KEY =
  process.env.DRIVE_SYNC_API_KEY || 'app_usage_sync_7f3a9c2e1b84d0f6';

function loadCredentials() {
  const localPath = path.join(__dirname, '..', 'secrets', 'service-account.json');
  if (fs.existsSync(localPath)) {
    return JSON.parse(fs.readFileSync(localPath, 'utf8'));
  }
  // Cloud Functions / Cloud Run: Application Default Credentials (runtime SA).
  return null;
}

async function getDriveClient() {
  const credentials = loadCredentials();
  const auth = credentials
    ? new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/drive'],
      })
    : new google.auth.GoogleAuth({
        scopes: ['https://www.googleapis.com/auth/drive'],
      });
  return google.drive({ version: 'v3', auth });
}

function setCors(res) {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, X-Api-Key');
}

function isValidUserId(userId) {
  return (
    typeof userId === 'string' &&
    /^[a-zA-Z0-9_-]{8,64}$/.test(userId)
  );
}

function normalizeDays(days) {
  if (!days || typeof days !== 'object' || Array.isArray(days)) {
    return null;
  }
  const out = {};
  for (const [date, apps] of Object.entries(days)) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) continue;
    if (!apps || typeof apps !== 'object' || Array.isArray(apps)) continue;
    const cleaned = {};
    for (const [pkg, seconds] of Object.entries(apps)) {
      const n = Number(seconds);
      if (!pkg || !Number.isFinite(n) || n < 0) continue;
      cleaned[pkg] = Math.floor(n);
    }
    out[date] = cleaned;
  }
  return out;
}

async function findExistingFile(drive, fileName) {
  const q = [
    `name = '${fileName.replace(/'/g, "\\'")}'`,
    `'${FOLDER_ID}' in parents`,
    'trashed = false',
  ].join(' and ');
  const listed = await drive.files.list({
    q,
    fields: 'files(id, name)',
    spaces: 'drive',
    pageSize: 1,
    supportsAllDrives: true,
    includeItemsFromAllDrives: true,
  });
  return listed.data.files?.[0] || null;
}

async function readJsonFile(drive, fileId) {
  const res = await drive.files.get(
    { fileId, alt: 'media', supportsAllDrives: true },
    { responseType: 'json' },
  );
  return res.data && typeof res.data === 'object' ? res.data : {};
}

async function upsertUserFile(drive, userId, incomingDays) {
  const fileName = `usage_${userId}.json`;
  const existing = await findExistingFile(drive, fileName);

  let mergedDays = { ...incomingDays };
  if (existing) {
    try {
      const previous = await readJsonFile(drive, existing.id);
      const prevDays =
        previous.days && typeof previous.days === 'object' ? previous.days : {};
      mergedDays = { ...prevDays, ...incomingDays };
    } catch (_) {
      // Overwrite with incoming payload if old file is unreadable.
    }
  }

  const payload = {
    userId,
    updatedAt: new Date().toISOString(),
    days: mergedDays,
  };
  const body = JSON.stringify(payload, null, 2);

  if (existing) {
    await drive.files.update({
      fileId: existing.id,
      media: {
        mimeType: 'application/json',
        body,
      },
      supportsAllDrives: true,
    });
    return { fileId: existing.id, fileName, created: false };
  }

  const created = await drive.files.create({
    requestBody: {
      name: fileName,
      parents: [FOLDER_ID],
      mimeType: 'application/json',
    },
    media: {
      mimeType: 'application/json',
      body,
    },
    fields: 'id, name',
    supportsAllDrives: true,
  });
  return { fileId: created.data.id, fileName, created: true };
}

functions.http('syncUsage', async (req, res) => {
  setCors(res);
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'POST only' });
    return;
  }

  const key = req.get('X-Api-Key') || '';
  if (key !== API_KEY) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  const userId = req.body?.userId;
  const days = normalizeDays(req.body?.days);
  if (!isValidUserId(userId) || !days || Object.keys(days).length === 0) {
    res.status(400).json({
      error: 'Expected { userId, days: { "YYYY-MM-DD": { "package": seconds } } }',
    });
    return;
  }

  try {
    const drive = await getDriveClient();
    const result = await upsertUserFile(drive, userId, days);
    res.status(200).json({ ok: true, ...result });
  } catch (err) {
    const message = err?.message || String(err);
    console.error('syncUsage failed', message);
    res.status(500).json({
      error: message,
      hint:
        'Share the Drive folder with the service account as Editor: app-usage-drive-uploader@silent-oasis-507819-k4.iam.gserviceaccount.com',
    });
  }
});

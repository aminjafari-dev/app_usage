'use strict';

const fs = require('fs');
const path = require('path');
const { google } = require('googleapis');

const FOLDER_ID =
  process.env.DRIVE_FOLDER_ID || '1bwuJe5xiUYW7PxqnaCJGmXngvpTt4ygz';
const credentialsPath = path.join(
  __dirname,
  '..',
  'secrets',
  'service-account.json',
);

async function main() {
  if (!fs.existsSync(credentialsPath)) {
    throw new Error(`Missing ${credentialsPath}`);
  }
  const credentials = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));
  const auth = new google.auth.GoogleAuth({
    credentials,
    scopes: ['https://www.googleapis.com/auth/drive'],
  });
  const drive = google.drive({ version: 'v3', auth });

  console.log('Service account:', credentials.client_email);
  console.log('Folder id:', FOLDER_ID);

  try {
    const meta = await drive.files.get({
      fileId: FOLDER_ID,
      fields: 'id, name, mimeType, capabilities',
      supportsAllDrives: true,
    });
    console.log('Folder OK:', meta.data.name);
    console.log('Can add children:', meta.data.capabilities?.canAddChildren);
  } catch (err) {
    console.error('Cannot access folder:', err.message);
    console.error(
      'Share the folder as Editor with:',
      credentials.client_email,
    );
    process.exitCode = 1;
  }
}

main();

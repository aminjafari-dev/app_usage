/**
 * Free Drive sync backend (Google Apps Script — no billing).
 *
 * SETUP (once):
 * 1. Open https://script.google.com → New project
 * 2. Delete the default code, paste THIS entire file
 * 3. Save (name it "AppUsage Drive Sync")
 * 4. Deploy → New deployment → Type: Web app
 *      - Execute as: Me
 *      - Who has access: Anyone
 * 5. Authorize when asked
 * 6. Copy the Web app URL (ends with /exec)
 * 7. Put that URL into Flutter as DRIVE_SYNC_URL (see drive_sync_config.dart / launch.json)
 *
 * Writes one file per user: usage_<userId>.json into FOLDER_ID.
 */

var FOLDER_ID = '1bwuJe5xiUYW7PxqnaCJGmXngvpTt4ygz';
var API_KEY = 'app_usage_sync_7f3a9c2e1b84d0f6';

function doGet() {
  return _json({ ok: true, service: 'app-usage-drive-sync' });
}

function doPost(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) {
      return _json({ ok: false, error: 'Empty body' }, 400);
    }

    var data = JSON.parse(e.postData.contents);
    var key = data.apiKey || '';
    if (key !== API_KEY) {
      return _json({ ok: false, error: 'Unauthorized' }, 401);
    }

    var userId = data.userId;
    var days = data.days;
    if (!_isValidUserId(userId) || !_isValidDays(days)) {
      return _json({
        ok: false,
        error: 'Expected { apiKey, userId, days: { "YYYY-MM-DD": { "package": seconds } } }',
      }, 400);
    }

    var result = _upsertUserFile(userId, days);
    return _json({ ok: true, fileName: result.fileName, created: result.created });
  } catch (err) {
    return _json({ ok: false, error: String(err) }, 500);
  }
}

function _upsertUserFile(userId, incomingDays) {
  var folder = DriveApp.getFolderById(FOLDER_ID);
  var fileName = 'usage_' + userId + '.json';
  var existing = _findFile(folder, fileName);

  var mergedDays = {};
  var created = true;

  if (existing) {
    created = false;
    try {
      var previous = JSON.parse(existing.getBlob().getDataAsString());
      if (previous && previous.days && typeof previous.days === 'object') {
        mergedDays = previous.days;
      }
    } catch (ignore) {
      // overwrite unreadable file
    }
  }

  var dates = Object.keys(incomingDays);
  for (var i = 0; i < dates.length; i++) {
    mergedDays[dates[i]] = incomingDays[dates[i]];
  }

  var payload = {
    userId: userId,
    updatedAt: new Date().toISOString(),
    days: mergedDays,
  };
  var body = JSON.stringify(payload, null, 2);

  if (existing) {
    existing.setContent(body);
  } else {
    folder.createFile(fileName, body, MimeType.PLAIN_TEXT);
  }

  return { fileName: fileName, created: created };
}

function _findFile(folder, fileName) {
  var files = folder.getFilesByName(fileName);
  return files.hasNext() ? files.next() : null;
}

function _isValidUserId(userId) {
  return typeof userId === 'string' && /^[a-zA-Z0-9_-]{8,64}$/.test(userId);
}

function _isValidDays(days) {
  if (!days || typeof days !== 'object' || Array.isArray(days)) return false;
  var keys = Object.keys(days);
  if (keys.length === 0) return false;
  for (var i = 0; i < keys.length; i++) {
    var date = keys[i];
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return false;
    var apps = days[date];
    if (!apps || typeof apps !== 'object' || Array.isArray(apps)) return false;
  }
  return true;
}

function _json(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

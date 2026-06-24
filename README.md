# Motion Data Evaluation Site

GitHub Pages에서 바로 열 수 있는 정적 평가 사이트입니다.

## What is included

- Main home with:
  - Data Quality 검증 1, 2, 3
  - Baseline 평가 1, 2, 3 placeholder links
- Data quality UI:
  - Source motion video from `m1.name`
  - Target motion video from `m2.name`
  - Final instruction from `instruction.final`
  - Instruction Quality yes/no
  - Editability yes/no
  - Optional comment
  - Per-dataset progress panel
  - Local autosave in the browser
  - JSON download fallback
  - Google Sheet submission hook

## Data JSON

Place your JSON files here:

```text
data/data-quality-1.json
data/data-quality-2.json
data/data-quality-3.json
```

Each file should be a JSON array like:

```json
[
  {
    "id": 6026,
    "m1": {
      "name": "G031T002A008R005",
      "org_des": "first person employs both hands..."
    },
    "m2": {
      "name": "G043T000A003R025",
      "org_des": "first person walks up..."
    },
    "instruction": {
      "final": "Change push into a walking approach, arm grab, and forward pull."
    }
  }
]
```

The page uses:

- `m1.name` as the source motion name
- `m2.name` as the target motion name
- `instruction.final` as the displayed instruction

If `instruction.final` is missing, the page falls back to `instruction.detail`.

## Motion videos

GitHub Pages cannot show videos from a local Windows path like:

```text
C:\Users\minye\motion_data\data\inter-x\vis_all
```

For people opening the shared GitHub Pages link, videos must be inside the repository or hosted at public URLs.

By default the site expects:

```text
assets/videos/G031T002A008R005_0.mp4
assets/videos/G043T000A003R025_0.mp4
```

The path pattern is:

```text
assets/videos/{motion_name}_0.mp4
```

To copy only the videos referenced by your JSON files, run this from the repo root in PowerShell:

```powershell
.\scripts\copy-motion-videos.ps1
```

The script reads all `data/*.json` files, finds every `m1.name` and `m2.name`, then copies matching `{name}_0.mp4` files from:

```text
C:\Users\minye\motion_data\data\inter-x\vis_all
```

into:

```text
assets/videos
```

## Connect Google Sheet

1. Create a Google Sheet.
2. Go to Extensions > Apps Script.
3. Paste this script.
4. Replace `SHEET_NAME` if needed.
5. Deploy > New deployment > Web app.
6. Set "Execute as" to yourself.
7. Set "Who has access" to anyone with the link.
8. Copy the Web app URL.
9. Paste it into `GOOGLE_SCRIPT_URL` in `index.html`.

```javascript
const SHEET_NAME = "Sheet1";

function doPost(e) {
  const payload = JSON.parse(e.postData.contents);
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);

  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      "submittedAt",
      "routeId",
      "datasetTitle",
      "reviewerName",
      "reviewerEmail",
      "order",
      "sampleId",
      "sourceName",
      "targetName",
      "sourceDescription",
      "targetDescription",
      "sourceVideo",
      "targetVideo",
      "instruction",
      "instructionQuality",
      "editability",
      "comment",
      "updatedAt"
    ]);
  }

  payload.answers.forEach((answer) => {
    sheet.appendRow([
      payload.submittedAt,
      payload.routeId,
      payload.datasetTitle,
      payload.reviewerName,
      payload.reviewerEmail,
      answer.order,
      answer.sampleId,
      answer.sourceName,
      answer.targetName,
      answer.sourceDescription,
      answer.targetDescription,
      answer.sourceVideo,
      answer.targetVideo,
      answer.instruction,
      answer.instructionQuality,
      answer.editability,
      answer.comment,
      answer.updatedAt
    ]);
  });

  return ContentService
    .createTextOutput(JSON.stringify({ ok: true }))
    .setMimeType(ContentService.MimeType.JSON);
}
```

## Local behavior

Answers are saved in each evaluator's browser local storage until submitted or downloaded. Refreshing the page does not erase progress on the same browser.

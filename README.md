# Motion Data Evaluation Site

GitHub Pages에서 바로 열 수 있는 정적 평가 사이트입니다.

## What is included

- Main home with:
  - Data Quality 검증 1, 2, 3
  - Baseline 평가 1, 2, 3 placeholder links
- Data quality UI:
  - Source motion video
  - Target motion video
  - Instruction text
  - Instruction Quality yes/no
  - Editability yes/no
  - Optional comment
  - 50-sample progress panel
  - Local autosave in the browser
  - JSON download fallback
  - Google Sheet submission hook

## Update sample data

Open `index.html` and edit the `createSamples` function or replace `DATASETS` with your real data.

Current expected video paths are:

```text
assets/data-quality-1/source_01.mp4
assets/data-quality-1/target_01.mp4
assets/data-quality-2/source_01.mp4
assets/data-quality-2/target_01.mp4
assets/data-quality-3/source_01.mp4
assets/data-quality-3/target_01.mp4
```

Add your videos under those folders, or change the paths in `index.html`.

## Connect Google Sheet

1. Create a Google Sheet.
2. Go to Extensions > Apps Script.
3. Paste this script.
4. Replace `YOUR_SHEET_NAME` if needed.
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

Answers are saved in each evaluator's browser local storage until submitted or downloaded. This means refreshing the page does not erase progress on the same browser.

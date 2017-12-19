const {app, microUI, dialog} = require('termipal');

const uiDef = [
  {
    "type": "label",
    "text": "Choose server:"
  },
  {
    "type": "popup",
    "id": "serverPopup",
    "items": [
      "cxhub154.example.com",
      "Option 2",
      "Option 3",
      "Option 4"
    ]
  },
  {
    "type": "label",
    "text": "Connect with private key:"
  },
  {
    "type": "popup",
    "id": "keyPopup",
    "items": [
      "foo-us-east-2",
      "foo-london",
      "foo-frankfurt",
      "foo-singapore"
    ]
  },
  
  {
    "type": "button",
    "id": "btn_showRepo",
    "action": "openRepoInBrowser",
    "text": "Show Github repo"
  },
  
];

app.on('ready', () => {
  microUI.loadUIDefinition(uiDef);
});

app.on('exit', () => {
  console.log(`Hello from termipal example - you selected server '${getSelectedItemForPopup('serverPopup')}' and key '${getSelectedItemForPopup('keyPopup')}'.`);
  // to print without newline at end, use process.stdout.write()
});

function getSelectedItemForPopup(popupId) {
  let selIdx = microUI.currentUIValues[popupId];
  for (let desc of uiDef) {
    if (desc.id === popupId) {
      return desc.items[selIdx];
    }
  }
  return null;
}

function openRepoInBrowser() {
  app.openUrl('https://github.com');
}


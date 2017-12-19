const {app, microUI, dialog} = require('termipal');

const uiDef = [
  {
    "type": "button",
    "id": "btn_chooseInput",
    "action": "chooseInput",
    "text": "Choose input file"
  },
  {
    "type": "label",
    "text": "Bitrate:"
  },
  {
    "type": "popup",
    "id": "bitratePopup",
    "items": [
      "500",
      "1000",
      "2000",
      "3000"
    ]
  },
];

let inputFile = null;

app.on('ready', () => {
  microUI.loadUIDefinition(uiDef);
});

app.on('exit', () => {
  // build ffmpeg command line, e.g:
  // ffmpeg -i input.mov -vf yadif  -c:v libvpx -pix_fmt yuva420p -b:v 500k -auto-alt-ref 0 -strict -2 output.webm
  
  if ( !inputFile) {
    console.error("** no input");
    return 1;
  }
  let outputFile = inputFile;
  const idx = outputFile.lastIndexOf('.');
  if (idx !== -1) {
    outputFile = outputFile.substr(0, idx);
  }
  outputFile += '.webm';
  
  const bitrate = getSelectedItemForPopup('bitratePopup');
  
  console.log(`ffmpeg -i "${inputFile}" -vf yadif  -c:v libvpx -pix_fmt yuva420p -b:v ${bitrate}k -auto-alt-ref 0 -strict -2 "${outputFile}"`);
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

function chooseInput() {
  dialog.showOpenDialog({
    title: "Input video file",
    filters: [
        { name: 'Movies', extensions: ['mov', 'mp4'] },
      ]
    }, (files) => {
      if (files)
        inputFile = files[0];
      
      // update the UI with a new label
      let newUiDef = uiDef.slice();
      newUiDef = newUiDef.concat({
        "type": "label",
        "text": "Input file: "+inputFile
      });
          
      // make sure popup maintains its selection
      const popupId = 'bitratePopup';
      let selIdx = microUI.currentUIValues[popupId];
      for (let desc of uiDef) {
        if (desc.id === popupId) {
          desc.defaultValue = selIdx;
        }
      }      
          
      microUI.loadUIDefinition(newUiDef);
    });
}


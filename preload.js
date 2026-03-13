const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  parseFile: (filePath, options) => ipcRenderer.invoke('parse-file', filePath, options),
  cleanData: (data) => ipcRenderer.invoke('clean-data', data),
  saveFile: (data, filePath, format) => ipcRenderer.invoke('save-file', data, filePath, format)
});

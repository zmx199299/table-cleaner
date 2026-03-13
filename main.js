const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { PythonShell } = require('python-shell');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile('renderer/index.html');

  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// IPC handlers
ipcMain.handle('parse-file', async (event, filePath, options) => {
  return new Promise((resolve, reject) => {
    PythonShell.run('python/file_parser.py', {
      mode: 'text',
      pythonPath: process.platform === 'win32' ? path.join(__dirname, 'venv/Scripts/python.exe') : path.join(__dirname, 'venv/bin/python'),
      args: [filePath, JSON.stringify(options)]
    }, (err, result) => {
      if (err) reject(err);
      else resolve(JSON.parse(result.join('')));
    });
  });
});

ipcMain.handle('clean-data', async (event, data) => {
  return new Promise((resolve, reject) => {
    PythonShell.run('python/data_cleaner.py', {
      mode: 'text',
      pythonPath: process.platform === 'win32' ? path.join(__dirname, 'venv/Scripts/python.exe') : path.join(__dirname, 'venv/bin/python'),
      args: [JSON.stringify(data)]
    }, (err, result) => {
      if (err) reject(err);
      else resolve(JSON.parse(result.join('')));
    });
  });
});

ipcMain.handle('save-file', async (event, data, filePath, format) => {
  return new Promise((resolve, reject) => {
    PythonShell.run('python/file_parser.py', {
      mode: 'text',
      pythonPath: process.platform === 'win32' ? path.join(__dirname, 'venv/Scripts/python.exe') : path.join(__dirname, 'venv/bin/python'),
      args: ['--save', JSON.stringify(data), filePath, format]
    }, (err, result) => {
      if (err) reject(err);
      else resolve(result.join(''));
    });
  });
});

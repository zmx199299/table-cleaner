// 应用状态
const appState = {
  targetFile: null,
  templateFile: null,
  targetSheets: [],
  selectedSheet: null,
  headerRow: 1,
  dateColumn: '',
  dateFormat: 'yyyymmdd',
  amountColumn: '',
  directionColumn: '',
  targetColumns: [],
  templateColumns: [],
  mappings: [],
  cleanedData: null
};

// DOM 元素
const elements = {
  // 文件输入
  targetFile: document.getElementById('targetFile'),
  templateFile: document.getElementById('templateFile'),
  targetFileName: document.getElementById('targetFileName'),
  templateFileName: document.getElementById('templateFileName'),
  
  // Sheet选择
  sheetSelection: document.getElementById('sheetSelection'),
  sheetList: document.getElementById('sheetList'),
  headerRow: document.getElementById('headerRow'),
  
  // 配置选择
  dateColumn: document.getElementById('dateColumn'),
  amountColumn: document.getElementById('amountColumn'),
  directionColumn: document.getElementById('directionColumn'),
  
  // 映射
  mappingDisplay: document.getElementById('mappingDisplay'),
  mappingTableBody: document.getElementById('mappingTableBody'),
  targetColumnSelect: document.getElementById('targetColumnSelect'),
  templateColumnSelect: document.getElementById('templateColumnSelect'),
  addMapping: document.getElementById('addMapping'),
  clearMappings: document.getElementById('clearMappings'),
  viewMappings: document.getElementById('viewMappings'),
  
  // 导出
  savePath: document.getElementById('savePath'),
  saveFilename: document.getElementById('saveFilename'),
  browsePath: document.getElementById('browsePath'),
  
  // 按钮
  nextToStep2: document.getElementById('nextToStep2'),
  nextToStep3: document.getElementById('nextToStep3'),
  backToStep1: document.getElementById('backToStep1'),
  backToStep2: document.getElementById('backToStep2'),
  startClean: document.getElementById('startClean')
};

// 步骤导航
function showStep(stepNumber) {
  document.querySelectorAll('.step').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.step-content').forEach(content => content.classList.remove('active'));
  
  document.querySelector(`.step[data-step="${stepNumber}"]`).classList.add('active');
  document.getElementById(`step-${stepNumber}`).classList.add('active');
}

// 导入目标文件
elements.targetFile.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  if (!file) return;
  
  appState.targetFile = file;
  elements.targetFileName.textContent = file.name;
  
  try {
    const result = await window.electronAPI.parseFile(file.path, { 
      action: 'get_sheets' 
    });
    
    appState.targetSheets = result.sheets;
    renderSheets(result.sheets);
    
  } catch (error) {
    console.error('解析目标文件失败:', error);
    alert('解析目标文件失败,请检查文件格式');
  }
});

// 导入模板文件
elements.templateFile.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  if (!file) return;
  
  appState.templateFile = file;
  elements.templateFileName.textContent = file.name;
  
  try {
    const result = await window.electronAPI.parseFile(file.path, { 
      action: 'get_columns',
      sheet: 0,
      headerRow: 1
    });
    
    appState.templateColumns = result.columns;
    renderColumnSelects(elements.dateColumn, result.columns);
    renderColumnSelects(elements.amountColumn, result.columns);
    renderColumnSelects(elements.directionColumn, result.columns);
    
  } catch (error) {
    console.error('解析模板文件失败:', error);
    alert('解析模板文件失败,请检查文件格式');
  }
});

// 渲染Sheet列表
function renderSheets(sheets) {
  elements.sheetSelection.classList.remove('hidden');
  elements.sheetList.innerHTML = '';
  
  sheets.forEach((sheet, index) => {
    const div = document.createElement('div');
    div.className = 'sheet-item';
    div.textContent = sheet;
    div.onclick = () => selectSheet(sheet, index, div);
    elements.sheetList.appendChild(div);
  });
}

// 选择Sheet
async function selectSheet(sheetName, index, element) {
  document.querySelectorAll('.sheet-item').forEach(item => item.classList.remove('selected'));
  element.classList.add('selected');
  
  appState.selectedSheet = sheetName;
  
  try {
    const result = await window.electronAPI.parseFile(appState.targetFile.path, {
      action: 'get_columns',
      sheet: index,
      headerRow: parseInt(elements.headerRow.value)
    });
    
    appState.targetColumns = result.columns;
    renderMappingColumnSelects();
    
  } catch (error) {
    console.error('获取列名失败:', error);
  }
}

// 渲染列选择器
function renderColumnSelects(selectElement, columns) {
  selectElement.innerHTML = '<option value="">请选择列</option>';
  columns.forEach(col => {
    const option = document.createElement('option');
    option.value = col;
    option.textContent = col;
    selectElement.appendChild(option);
  });
}

// 渲染映射列选择器
function renderMappingColumnSelects() {
  renderColumnSelects(elements.targetColumnSelect, appState.targetColumns);
  renderColumnSelects(elements.templateColumnSelect, appState.templateColumns);
}

// 添加映射
elements.addMapping.addEventListener('click', () => {
  const targetCol = elements.targetColumnSelect.value;
  const templateCol = elements.templateColumnSelect.value;
  
  if (!targetCol || !templateCol) {
    alert('请选择目标列和模板列');
    return;
  }
  
  if (appState.mappings.find(m => m.target === targetCol)) {
    alert('该目标列已经映射过了');
    return;
  }
  
  appState.mappings.push({ target: targetCol, template: templateCol });
  renderMappings();
  renderUnmappedColumns();
});

// 渲染映射
function renderMappings() {
  elements.mappingTableBody.innerHTML = '';
  
  appState.mappings.forEach((mapping, index) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${mapping.target}</td>
      <td>→</td>
      <td>${mapping.template}</td>
      <td><button class="btn-danger delete-mapping" data-index="${index}">删除</button></td>
    `;
    elements.mappingTableBody.appendChild(tr);
  });
  
  // 绑定删除按钮
  document.querySelectorAll('.delete-mapping').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const index = parseInt(e.target.dataset.index);
      appState.mappings.splice(index, 1);
      renderMappings();
      renderUnmappedColumns();
    });
  });
}

// 渲染未映射的列
function renderUnmappedColumns() {
  const mappedTargetCols = appState.mappings.map(m => m.target);
  const mappedTemplateCols = appState.mappings.map(m => m.template);
  
  const unmappedTarget = appState.targetColumns.filter(col => !mappedTargetCols.includes(col));
  const unmappedTemplate = appState.templateColumns.filter(col => !mappedTemplateCols.includes(col));
  
  document.getElementById('unmappedTarget').innerHTML = 
    unmappedTarget.length ? unmappedTarget.map(col => `<li>${col}</li>`).join('') : '<li>无</li>';
  
  document.getElementById('unmappedTemplate').innerHTML = 
    unmappedTemplate.length ? unmappedTemplate.map(col => `<li>${col}</li>`).join('') : '<li>无</li>';
}

// 清空所有映射
elements.clearMappings.addEventListener('click', () => {
  if (confirm('确定要清空所有映射关系吗?')) {
    appState.mappings = [];
    renderMappings();
    renderUnmappedColumns();
  }
});

// 查看当前映射
elements.viewMappings.addEventListener('click', () => {
  if (appState.mappings.length === 0) {
    alert('当前没有映射关系');
    return;
  }
  
  const mappingText = appState.mappings.map(m => `${m.target} → ${m.template}`).join('\n');
  alert(`当前映射关系:\n\n${mappingText}`);
});

// 下一步按钮
elements.nextToStep2.addEventListener('click', () => {
  if (!appState.targetFile || !appState.templateFile) {
    alert('请先导入目标文件和模板文件');
    return;
  }
  
  appState.headerRow = parseInt(elements.headerRow.value);
  appState.dateColumn = elements.dateColumn.value;
  appState.dateFormat = document.querySelector('input[name="dateFormat"]:checked').value;
  appState.amountColumn = elements.amountColumn.value;
  appState.directionColumn = elements.directionColumn.value;
  
  if (!appState.selectedSheet && appState.targetSheets.length > 0) {
    alert('请选择一个Sheet页面');
    return;
  }
  
  showStep(2);
});

elements.nextToStep3.addEventListener('click', () => {
  if (appState.mappings.length === 0) {
    alert('请至少添加一个映射关系');
    return;
  }
  
  showStep(3);
});

// 返回按钮
elements.backToStep1.addEventListener('click', () => showStep(1));
elements.backToStep2.addEventListener('click', () => showStep(2));

// 浏览保存路径
elements.browsePath.addEventListener('click', async () => {
  const { path } = await window.electronAPI.showSaveDialog({
    defaultPath: '清洗后数据.xlsx',
    filters: [
      { name: 'Excel', extensions: ['xlsx'] },
      { name: 'CSV', extensions: ['csv'] }
    ]
  });
  
  if (path) {
    const parts = path.split('/');
    elements.savePath.value = parts.slice(0, -1).join('/');
    elements.saveFilename.value = parts[parts.length - 1].replace(/\.(xlsx|csv)$/, '');
  }
});

// 开始清洗
elements.startClean.addEventListener('click', async () => {
  if (!elements.savePath.value) {
    alert('请选择保存路径');
    return;
  }
  
  try {
    const saveFormat = document.querySelector('input[name="saveFormat"]:checked').value;
    const fullPath = `${elements.savePath.value}/${elements.saveFilename.value}.${saveFormat === 'excel' ? 'xlsx' : 'csv'}`;
    
    const result = await window.electronAPI.cleanData({
      targetFile: appState.targetFile.path,
      templateFile: appState.templateFile.path,
      sheet: appState.selectedSheet,
      headerRow: appState.headerRow,
      mappings: appState.mappings,
      dateColumn: appState.dateColumn,
      dateFormat: appState.dateFormat,
      amountColumn: appState.amountColumn,
      directionColumn: appState.directionColumn
    });
    
    // 显示清洗结果
    displayCleanResult(result);
    
    // 保存文件
    await window.electronAPI.saveFile(result.data, fullPath, saveFormat);
    
    alert(`清洗完成! 文件已保存到:\n${fullPath}`);
    
  } catch (error) {
    console.error('清洗失败:', error);
    alert('清洗失败: ' + error.message);
  }
});

// 显示清洗结果
function displayCleanResult(result) {
  const statistics = document.getElementById('statistics');
  statistics.innerHTML = `
    <p>日期格式转换: ${result.dateConversion.success}/${result.dateConversion.total} (${result.dateConversion.rate}%)</p>
    <p>金额正负号补全: ${result.amountSign.success}/${result.amountSign.total} (${result.amountSign.rate}%)</p>
    <p>列映射应用: 完成</p>
    <p>数据行数: ${result.rowCount}</p>
  `;
  
  // 显示预览
  const previewTable = document.getElementById('previewTable');
  previewTable.innerHTML = generatePreviewTable(result.preview);
}

// 生成预览表格
function generatePreviewTable(preview) {
  if (!preview || preview.length === 0) return '<p>无数据</p>';
  
  const headers = Object.keys(preview[0]).map(key => `<th>${key}</th>`).join('');
  const rows = preview.map(row => {
    const cells = Object.values(row).map(val => `<td>${val}</td>`).join('');
    return `<tr>${cells}</tr>`;
  }).join('');
  
  return `<thead><tr>${headers}</tr></thead><tbody>${rows}</tbody>`;
}

// 页面加载时设置默认保存路径
window.addEventListener('DOMContentLoaded', () => {
  const defaultPath = '/mnt/c/Users/zmx19/OneDrive/私人';
  elements.savePath.value = defaultPath;
});

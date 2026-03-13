import sys
import json
import pandas as pd
from typing import Dict, List, Any

def get_excel_sheets(file_path: str) -> List[str]:
    """获取Excel文件的所有Sheet名称"""
    try:
        excel_file = pd.ExcelFile(file_path)
        return excel_file.sheet_names
    except Exception as e:
        raise ValueError(f"无法读取Excel文件: {str(e)}")

def get_columns(file_path: str, sheet: int = 0, header_row: int = 1) -> List[str]:
    """获取文件的列名"""
    try:
        # header_row 是从1开始计数的,pandas从0开始
        header_row = header_row - 1
        
        if file_path.endswith('.csv'):
            df = pd.read_csv(file_path, header=header_row)
        else:
            df = pd.read_excel(file_path, sheet_name=sheet, header=header_row)
        
        return df.columns.tolist()
    except Exception as e:
        raise ValueError(f"无法读取文件列名: {str(e)}")

def read_file(file_path: str, sheet: int = 0, header_row: int = 1) -> pd.DataFrame:
    """读取文件为DataFrame"""
    try:
        header_row = header_row - 1
        
        if file_path.endswith('.csv'):
            df = pd.read_csv(file_path, header=header_row)
        else:
            df = pd.read_excel(file_path, sheet_name=sheet, header=header_row)
        
        return df
    except Exception as e:
        raise ValueError(f"无法读取文件: {str(e)}")

def save_file(data: pd.DataFrame, file_path: str, format_type: str = 'excel') -> str:
    """保存DataFrame到文件"""
    try:
        if format_type == 'csv':
            data.to_csv(file_path, index=False, encoding='utf-8-sig')
        else:
            data.to_excel(file_path, index=False, engine='openpyxl')
        return file_path
    except Exception as e:
        raise ValueError(f"无法保存文件: {str(e)}")

def main():
    if len(sys.argv) < 3:
        print(json.dumps({"error": "参数不足"}))
        return
    
    action = sys.argv[1]
    
    try:
        if action == '--get-sheets':
            file_path = sys.argv[2]
            sheets = get_excel_sheets(file_path)
            print(json.dumps({"sheets": sheets}, ensure_ascii=False))
            
        elif action == '--get-columns':
            file_path = sys.argv[2]
            options = json.loads(sys.argv[3])
            columns = get_columns(file_path, options.get('sheet', 0), options.get('headerRow', 1))
            print(json.dumps({"columns": columns}, ensure_ascii=False))
            
        elif action == '--read':
            file_path = sys.argv[2]
            options = json.loads(sys.argv[3])
            df = read_file(file_path, options.get('sheet', 0), options.get('headerRow', 1))
            print(json.dumps({
                "data": df.to_dict(orient='records'),
                "rowCount": len(df),
                "columns": df.columns.tolist()
            }, ensure_ascii=False))
            
        elif action == '--save':
            data_json = sys.argv[2]
            file_path = sys.argv[3]
            format_type = sys.argv[4] if len(sys.argv) > 4 else 'excel'
            
            data = pd.DataFrame(json.loads(data_json))
            result = save_file(data, file_path, format_type)
            print(json.dumps({"success": True, "filePath": result}, ensure_ascii=False))
            
        else:
            print(json.dumps({"error": "未知操作"}))
            
    except Exception as e:
        print(json.dumps({"error": str(e)}, ensure_ascii=False))

if __name__ == '__main__':
    main()

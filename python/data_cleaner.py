import sys
import json
import pandas as pd
from file_parser import read_file, save_file
from date_handler import convert_column_to_dates

def apply_mapping(df: pd.DataFrame, mappings: list) -> pd.DataFrame:
    """应用列映射"""
    # 创建新的DataFrame
    mapped_data = {}
    
    # 添加映射的列
    for mapping in mappings:
        target_col = mapping['target']
        template_col = mapping['template']
        if target_col in df.columns:
            mapped_data[template_col] = df[target_col].copy()
    
    # 添加未映射的模板列为空
    template_columns = [m['template'] for m in mappings]
    all_template_columns = set([m['template'] for m in mappings])
    
    # 获取模板文件中的所有列(如果有模板文件的话)
    # 这里简化处理,只使用映射的列
    
    return pd.DataFrame(mapped_data)

def process_date_column(df: pd.DataFrame, date_column: str, date_format: str) -> Tuple[pd.DataFrame, dict]:
    """处理日期列"""
    if not date_column or date_column not in df.columns:
        return df, {'total': 0, 'success': 0, 'failed': 0, 'rate': '0.0'}
    
    converted_col, stats = convert_column_to_dates(df[date_column], date_format)
    df[date_column] = converted_col
    
    return df, stats

def process_amount_columns(df: pd.DataFrame, amount_column: str, direction_column: str) -> Tuple[pd.DataFrame, dict]:
    """处理金额列,根据方向列添加正负号"""
    if not amount_column or amount_column not in df.columns:
        return df, {'total': 0, 'success': 0, 'failed': 0, 'rate': '0.0'}
    
    df[amount_column] = pd.to_numeric(df[amount_column], errors='coerce')
    
    total = len(df)
    success = 0
    
    if direction_column and direction_column in df.columns:
        for idx, row in df.iterrows():
            amount = row[amount_column]
            direction = str(row[direction_column]).strip()
            
            if pd.isna(amount):
                continue
            
            # 根据方向添加符号
            if direction in ['收入', '入', '+', '进', '存']:
                if amount < 0:
                    df.at[idx, amount_column] = abs(amount)
                    success += 1
                else:
                    success += 1
            elif direction in ['支出', '出', '-', '转', '提']:
                if amount > 0:
                    df.at[idx, amount_column] = -abs(amount)
                    success += 1
                else:
                    success += 1
    else:
        # 没有方向列,不处理
        success = total
    
    stats = {
        'total': total,
        'success': success,
        'failed': total - success,
        'rate': f"{(success / total * 100):.1f}" if total > 0 else '0.0'
    }
    
    return df, stats

def clean_data(params: dict) -> dict:
    """执行数据清洗"""
    try:
        # 读取目标文件
        df = read_file(
            params['targetFile'],
            sheet=params.get('sheet', 0),
            header_row=params.get('headerRow', 1)
        )
        
        # 应用列映射
        df = apply_mapping(df, params['mappings'])
        
        # 处理日期列
        date_stats = {}
        if params.get('dateColumn'):
            df, date_stats = process_date_column(
                df, 
                params['dateColumn'], 
                params.get('dateFormat', 'yyyymmdd')
            )
        
        # 处理金额列
        amount_stats = {}
        if params.get('amountColumn'):
            df, amount_stats = process_amount_columns(
                df,
                params['amountColumn'],
                params.get('directionColumn')
            )
        
        # 准备预览数据(前5行)
        preview = df.head(5).to_dict(orient='records')
        
        # 转换数据为JSON可序列化格式
        data = df.fillna('').to_dict(orient='records')
        
        return {
            'success': True,
            'data': data,
            'preview': preview,
            'rowCount': len(df),
            'columns': df.columns.tolist(),
            'dateConversion': date_stats,
            'amountSign': amount_stats
        }
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "参数不足"}))
        return
    
    try:
        params = json.loads(sys.argv[1])
        result = clean_data(params)
        print(json.dumps(result, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"error": str(e)}, ensure_ascii=False))

if __name__ == '__main__':
    main()

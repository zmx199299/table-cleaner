import re
from datetime import datetime
from typing import Tuple, Optional

def parse_date(date_str: str) -> Optional[Tuple[str, int]]:
    """
    解析日期字符串,返回标准化日期和补全位数
    
    支持格式:
    - yyyymmdd: 20240315
    - yymdd: 240315
    - yymmd: 2403/15 或 2403.15
    
    Returns:
        (标准化日期字符串, 补全位数) 或 None
    """
    if pd.isna(date_str):
        return None
    
    date_str = str(date_str).strip()
    
    # 尝试匹配不同格式
    patterns = [
        (r'^(\d{4})(\d{2})(\d{2})$', 'yyyymmdd'),        # 20240315
        (r'^(\d{2})(\d{2})(\d{2})$', 'yymdd'),          # 240315
        (r'^(\d{2})[/.-](\d{2})[/.-](\d{2})$', 'yymmd'), # 24/03/15
    ]
    
    for pattern, format_type in patterns:
        match = re.match(pattern, date_str)
        if match:
            if format_type == 'yyyymmdd':
                year, month, day = match.groups()
                # 补全年份为4位
                year = year.zfill(4)
                if int(year) < 100:
                    year = '20' + year.zfill(2)
                return f"{year}{month}{day}", 0
            
            elif format_type == 'yymdd':
                yy, mm, dd = match.groups()
                # 补全年份为4位
                if int(yy) < 50:
                    year = '20' + yy.zfill(2)
                else:
                    year = '19' + yy.zfill(2)
                return f"{year}{mm.zfill(2)}{dd.zfill(2)}", 0
            
            elif format_type == 'yymmd':
                yy, mm, dd = match.groups()
                # 补全年份为4位
                if int(yy) < 50:
                    year = '20' + yy.zfill(2)
                else:
                    year = '19' + yy.zfill(2)
                return f"{year}{mm.zfill(2)}{dd.zfill(2)}", 0
    
    return None

def convert_date_format(date_str: str, target_format: str) -> Tuple[str, int, bool]:
    """
    转换日期格式为目标格式
    
    Args:
        date_str: 原始日期字符串
        target_format: 目标格式 'yyyymmdd' 或 'yyyymmddhhmmss'
    
    Returns:
        (转换后的日期字符串, 补全位数, 是否成功)
    """
    parsed = parse_date(date_str)
    
    if not parsed:
        return date_str, 0, False
    
    date_part, _ = parsed
    
    # 检查是否包含时间部分
    has_time = len(date_str) > 8 and any(c in date_str for c in [' ', ':', '时', '分'])
    
    if target_format == 'yyyymmdd':
        # 目标格式是 yyyymmdd,只返回日期部分
        return date_part[:8], 0, True
    
    elif target_format == 'yyyymmddhhmmss':
        # 目标格式是 yyyymmddhhmmss,需要补全时间部分
        if has_time:
            # 尝试解析时间部分
            time_part = date_str[8:].strip()
            time_match = re.search(r'(\d{1,2})[:时](\d{1,2})[:分]?(\d{1,2})?', time_part)
            if time_match:
                h, m, s = time_match.groups()
                time_str = f"{int(h or 0):02d}{int(m or 0):02d}{int(s or 0):02d}"
                return date_part[:8] + time_str, 0, True
        
        # 没有时间部分,补全为 000000
        return date_part[:8] + '000000', 6, True
    
    return date_part, 0, False

def convert_column_to_dates(column, target_format: str) -> Tuple[list, dict]:
    """
    将列转换为日期格式
    
    Args:
        column: pandas Series 或 list
        target_format: 目标格式
    
    Returns:
        (转换后的列, 统计信息)
    """
    converted = []
    success = 0
    total = 0
    
    for value in column:
        total += 1
        if pd.isna(value):
            converted.append('')
            continue
        
        result, _, is_success = convert_date_format(str(value), target_format)
        converted.append(result)
        
        if is_success:
            success += 1
    
    stats = {
        'total': total,
        'success': success,
        'failed': total - success,
        'rate': f"{(success / total * 100):.1f}" if total > 0 else '0.0'
    }
    
    return converted, stats

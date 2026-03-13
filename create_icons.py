from PIL import Image, ImageDraw

# 创建一个简单的表格图标
def create_icon(size, output_path):
    # 创建透明背景
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制表格图标 (简单的网格)
    margin = size // 8
    icon_size = size - 2 * margin
    cell_size = icon_size // 3
    
    # 绘制背景圆角矩形
    draw.rounded_rectangle(
        [margin, margin, margin + icon_size, margin + icon_size],
        radius=size // 10,
        fill=(66, 133, 244, 255),  # 蓝色
        outline=(255, 255, 255, 255),
        width=2
    )
    
    # 绘制网格线
    for i in range(1, 3):
        # 横线
        y = margin + i * cell_size
        draw.line([margin, y, margin + icon_size, y], fill=(255, 255, 255, 200), width=2)
        # 竖线
        x = margin + i * cell_size
        draw.line([x, margin, x, margin + icon_size], fill=(255, 255, 255, 200), width=2)
    
    # 保存
    img.save(output_path)

# 创建不同格式的图标
create_icon(512, 'icon.png')
print('✅ Created icon.png')

# 保存为 .ico
img = Image.open('icon.png')
img.save('icon.ico', format='ICO', sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])
print('✅ Created icon.ico')

# 创建 .icns 占位符
# 注意: 真正的 .icns 需要 macOS 工具,这里创建一个最小化版本
with open('icon.icns', 'wb') as f:
    f.write(b'icns')
    f.write((0).to_bytes(4, 'big'))
print('✅ Created icon.icns (placeholder)')

print('')
print('所有图标文件已创建!')

from PIL import Image

def img_to_mips_asm(image_path, output_file, desired_width, desired_height):
    img = Image.open(image_path)
    img = img.resize((desired_width, desired_height), Image.ANTIALIAS)
    width, height = img.size
    img = img.convert('RGB')

    with open(output_file, 'w') as f:
        f.write('.data\n')
        f.write('    .word ')

        pixel_count = 0

        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                color = (r << 16) | (g << 8) | b
                f.write(f'0x{color:08X}')

                pixel_count += 1

                if pixel_count % 512 == 0:
                    f.write(',\n           ')
                else:
                    f.write(', ')

        f.write('\n')
        f.write('\n')


if name == "main":
    img_to_mips_asm(r'C:\Users\ansha\Downloads\level_3.png', 'output_mips.asm', 64, 128)
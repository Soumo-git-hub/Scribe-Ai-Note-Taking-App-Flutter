$fontUrls = @{
    "NotoSans-Regular.ttf" = "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf"
    "NotoSans-Bold.ttf" = "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf"
    "NotoSans-Italic.ttf" = "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Italic.ttf"
    "NotoSans-BoldItalic.ttf" = "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-BoldItalic.ttf"
}

foreach ($font in $fontUrls.GetEnumerator()) {
    $outputPath = "assets\fonts\$($font.Key)"
    Write-Host "Downloading $($font.Key)..."
    Invoke-WebRequest -Uri $font.Value -OutFile $outputPath
} 
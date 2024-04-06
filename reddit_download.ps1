Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Download Video'
$form.Size = New-Object Drawing.Size(500,200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog' 
$form.BackColor = 'White' 

$logoUrl = 'https://cdn3.iconfinder.com/data/icons/2018-social-media-logotypes/1000/2018_social_media_popular_app_logo_reddit-512.png'
$logoImage = [System.Drawing.Image]::FromStream((New-Object System.Net.WebClient).OpenRead($logoUrl))
$logoPictureBox = New-Object System.Windows.Forms.PictureBox
$logoPictureBox.Image = $logoImage
$logoPictureBox.SizeMode = 'Zoom'
$logoPictureBox.Size = New-Object Drawing.Size(100, 100)
$logoPictureBox.Location = New-Object Drawing.Point(380, 30)
$form.Controls.Add($logoPictureBox)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object Drawing.Point(20,30)
$label.Size = New-Object Drawing.Size(100,20)
$label.Text = 'Video URL:'
$label.Font = New-Object System.Drawing.Font('Arial',10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object Drawing.Point(120,30)
$textbox.Size = New-Object Drawing.Size(240,20)
$textbox.Font = New-Object System.Drawing.Font('Arial',10)
$form.Controls.Add($textbox)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object Drawing.Point(20,70)
$button.Size = New-Object Drawing.Size(120,30)
$button.Text = 'Download'
$button.Font = New-Object System.Drawing.Font('Arial',10)
$button.BackColor = 'LightSkyBlue' 
$button.ForeColor = 'White' 
$form.Controls.Add($button)
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object Drawing.Point(20,110)
$statusLabel.Size = New-Object Drawing.Size(450,40)
$statusLabel.Font = New-Object System.Drawing.Font('Arial',10)
$form.Controls.Add($statusLabel)

function DownloadVideo {
    param(
        [string]$url,
        [string]$filePath
    )

    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing
        [System.IO.File]::WriteAllBytes($filePath, $response.Content)
        $statusLabel.Text = "Video downloaded successfully to $filePath"
    } catch {
        $statusLabel.Text = "An error occurred: $_"
        Write-Host "An error occurred: $_"
    }
}

function Get-FileSavePath {
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
    $saveFileDialog.filter = "MP4 files (*.mp4)|*.mp4|All files (*.*)|*.*"
    $saveFileDialog.FileName = "DownloadedVideo.mp4"
    $saveFileDialog.Title = "Select a location to save the video"

    $result = $saveFileDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $saveFileDialog.FileName
    } else {
        return $null
    }
}

$button.Add_Click({
    $statusLabel.Text = "Preparing to download..."
    $filePath = Get-FileSavePath
    if ($null -ne $filePath) {
        $statusLabel.Text = "Downloading..."
        DownloadVideo -url $textbox.Text -filePath $filePath
    } else {
        $statusLabel.Text = "Operation cancelled by the user."
    }
})

$form.ShowDialog()

# ------------ Presets ------------
$mapImage = "https://raw.githubusercontent.com/jgiboney/mmo-map/refs/heads/main/Wild%20Ends%20Map.png"   # Set the URL of the map image


# Define the XAML for the GUI
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="Pantheon MMO Map" 
        Height="280" 
        Width="250" 
        WindowStartupLocation="Manual" 
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        >
    <Grid>
        <!-- Add a background ellipse to the Window -->
        <Ellipse Stroke="Black" Fill="Black" Width="250" Height="250" VerticalAlignment="Top" Margin="0,0,0,0" Opacity="0.9" />
        <!-- Add an Image to the Window -->
        <Image Name="MyImage" HorizontalAlignment="Left" VerticalAlignment="Top" Width="250" Height="286" Margin="0,0,0,0">
            <Image.Clip>
            <EllipseGeometry x:Name="MapClip"
            RadiusX="120"
            RadiusY="120"
            Center="125,125"
            />
            </Image.Clip>
        </Image>
        <!-- Add a center red ellipse to the Window -->
        <Ellipse Name="TargetPoint" Fill="DarkRed" Width="5" Height="5" VerticalAlignment="Top" Margin="0,120,0,0" Opacity="0.9" />
        <!-- Buttons -->
        <Rectangle Fill="Black" Height="26" VerticalAlignment="Top" Opacity="0.9" Width="106" Margin="0,258,0,0"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top" Margin="0,260,5,3">
            <Button x:Name="CloseButton" Content="x" Width="20" Height="20" Background="DarkRed" Foreground="White" Margin="5,0,0,0"/>
            <Button x:Name="ZoomInButton" Content="+" Width="20" Height="20" Background="#333333" Foreground="White"/>
            <Button x:Name="ZoomOutButton" Content="-" Width="20" Height="20" Background="#333333" Foreground="White"/>
            <Button x:Name="UpdateLocationButton" Content="U" Width="20" Height="20" Background="DarkMagenta" Foreground="White"/>
            <!-- <Button x:Name="AutoRunButton" Content="A" Width="20" Height="20" Background="DarkGreen" Foreground="White"/> -->
        </StackPanel>
    </Grid>
</Window>
"@

# Create a new shell object
$wshell = New-Object -ComObject wscript.shell;

# Create the GUI
Add-Type -AssemblyName PresentationFramework
$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Get the screen's working area (adjusts for taskbars, etc.)
$screenWidth = [System.Windows.SystemParameters]::PrimaryScreenWidth
$windowWidth = $Window.Width
$Window.Left = $screenWidth - $windowWidth - 5  # Position the window on the right edge
$Window.Top = 5  # Position the window at the top


# Close Button Functionality
$Window.FindName("CloseButton").Add_Click({
    $Window.Close()
})

# Zoom In Functionality
$Window.FindName("ZoomInButton").Add_Click({
    if ($Window.Height+20 -lt [System.Windows.SystemParameters]::PrimaryScreenHeight) { # Check if the window height is less than the screen height
        $Window.Height = $Window.Height + 100                # Increase the window height (from the bottom left corner)
        $Window.Width = $Window.Width + 100                  # Increase the window width (from the bottom left corner)
        $Window.Left = $Window.Left - 50.05                 # Move the window to the right
        $MyImage = $Window.FindName("MyImage")              # Get the Image control
        $MyImage.Width += 100                                # Increase the image width
        $MyImage.Height += 100                               # Increase the image height
        #$MapClip = $Window.FindName("MapClip")              # Get the clipping geometry
        #$HalfWidth = ($MyImage.Width)/2                     # Calculate the half width of the image
        #$MapClip.Center = $HalfWidth.ToString()+",125"     # Update the center of the clipping geometry
        UpdateMap
    }
})

# Zoom Out Functionality
$Window.FindName("ZoomOutButton").Add_Click({
    if ($Window.Height -gt 280) {                           # Check if the window height is greater than 280
        $Window.Height = $Window.Height - 100                # Decrease the window height (from the bottom left corner)
        $Window.Width = $Window.Width - 100                  # Decrease the window width (from the bottom left corner)
        $Window.Left = $Window.Left + 50.05                 # Move the window to the left
        $MyImage = $Window.FindName("MyImage")              # Get the Image control
        $MyImage.Width -= 100                                # Decrease the image width
        $MyImage.Height -= 100                               # Decrease the image height
        #$MapClip = $Window.FindName("MapClip")              # Get the clipping geometry
        #$HalfWidth = ($MyImage.Width)/2                     # Calculate the half width of the image
        #$MapClip.Center = $HalfWidth.ToString()+",125"      # Update the center of the clipping geometry
        UpdateMap
    }
})


function UpdateMap () {
    # Get the current margin of the image
    $MyImage = $Window.FindName("MyImage")                  # Get the Image control
    $Margin = $MyImage.Margin                               # Get the current margin
    # Split the string into 4 values (left, top, right, bottom)
    $MarginValues = $Margin -split ","
    $wshell.AppActivate('Pantheon') # Activate the Pantheon window
    # Type /loc
    $wshell.SendKeys('{ENTER}')
    Start-Sleep -Milliseconds 100
    $wshell.SendKeys('/loc')
    Start-Sleep -Milliseconds 100
    $wshell.SendKeys('{ENTER}')
    Start-Sleep -Milliseconds 100
    # Grab the clipboard
    $clipboard = (Get-Clipboard)
    # print the clipboard
    # Split the clipboard into 5 values (name, x, z, y, heading)
    $locValues = $clipboard -split " "
    # Adjust the margin based on the x and y values
    # Current coords min = 2103.26, -4189.89 max = 4568.41, -1365.48
    # Get the percentage of the current location in relation to the map
    $xPercent = ($locValues[1] - 2103.26) / (4568.41 - 2103.26) # Middle is 3335.835
    $yPercent = ($locValues[3] - -4189.89) / (-1365.48 - -4189.89) # Middle is -2777.185
    $xPercent = $xPercent - .5
    $yPercent = $yPercent - .5
    # Calculate the new margin based on the percentage
    $newLeft = -($xPercent * $MyImage.Width)
    $yModifier = 15
    $newTop = ($yPercent * $MyImage.Height) - $yModifier
    $MyImage.Margin = "$newLeft,$newTop,0,0"
    # Update the clip
    $MapClip = $Window.FindName("MapClip")              # Get the clipping geometry
    $newCenter = (-$newLeft + $MyImage.Width/2).ToString()+","+(-$newTop-$yModifier + $MyImage.Height/2).ToString()     # Update the center of the clipping geometry
    $MapClip.Center = $newCenter
}

# Update Location Functionality
$Window.FindName("UpdateLocationButton").Add_Click({
    UpdateMap
})

$autoRun = $false
$timer = New-Object System.Timers.Timer

# # Auto Run Functionality
# $Window.FindName("AutoRunButton").Add_Click({
#     if ($global:autoRun -eq $true) {
#         $autoRun = $false
#         Write-Host "Auto Run Disabled"
#         $Window.FindName("AutoRunButton").Background = "DarkGreen"
#         # Stop the timer
#         $t = $global:timer
#         $t.Stop()
#     } else {
#         $global:autoRun = $true
#         Write-Host "Auto Run Enabled"
#         $Window.FindName("AutoRunButton").Background = "LightGreen"
#         # Update the map every 5 seconds
#         $t = $global:timer
#         $t.Interval = 5000
#         $t.AutoReset = $true
#         $t.Enabled = $true
#         $t.add_Elapsed({
#             Write-Host "Updating Map"
#             UpdateMap
#         })
#         # Start the timer
#         $t.Start()
#     }
# })

# Load the image into the Image control
$imageUrl = $mapImage  # Specify your image file path
try {
    $Bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
    $Bitmap.BeginInit()
    $Bitmap.UriSource = New-Object System.Uri($imageUrl, [System.UriKind]::Absolute)
    $Bitmap.EndInit()
    $Window.FindName("MyImage").Source = $Bitmap
} catch {
    Write-Host "Failed to load image from URL: $_"
}

# Show the window
$Window.ShowDialog() | Out-Null
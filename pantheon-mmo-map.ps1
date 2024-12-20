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
        Background="Green"
        Topmost="True"
        >
    <Grid>
        <!-- Add an Image to the Window -->
        <Ellipse Stroke="Black" Fill="Black" Width="250" Height="250" VerticalAlignment="Top" Margin="0,0,0,0" Opacity="0.9" />
        <ScrollViewer Grid.Row="1">
            <ScrollViewer.Style>
                <Style TargetType="{x:Type ScrollViewer}">
                    <Setter Property="HorizontalScrollBarVisibility" Value="Disabled"/>
                    <Setter Property="VerticalScrollBarVisibility" Value="Disabled"/>
                    <Style.Triggers>
                        <DataTrigger Binding="{Binding IsChecked, ElementName=chkActualSize}" Value="True">
                            <Setter Property="HorizontalScrollBarVisibility" Value="Auto"/>
                            <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
                        </DataTrigger>
                    </Style.Triggers>
                </Style>
            </ScrollViewer.Style>
            <Image Name="MyImage" HorizontalAlignment="Center" VerticalAlignment="Center" Width="200">
                <Image.Clip>
                <EllipseGeometry
                RadiusX="120"
                RadiusY="120"
                Center="127,125"
                />
                </Image.Clip>
            </Image>
        </ScrollViewer>
        
        <!-- Buttons -->
        <Rectangle Fill="Black" Height="26" VerticalAlignment="Bottom" Opacity="0.9" Width="106"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,5,3">
            <Button x:Name="CloseButton" Content="x" Width="20" Height="20" Background="DarkRed" Foreground="White" Margin="5,0,0,0"/>
            <Button x:Name="ZoomInButton" Content="+" Width="20" Height="20" Background="#333333" Foreground="White"/>
            <Button x:Name="ZoomOutButton" Content="-" Width="20" Height="20" Background="#333333" Foreground="White"/>
            <Button x:Name="UpdateLocationButton" Content="U" Width="20" Height="20" Background="DarkMagenta" Foreground="White"/>
            <Button x:Name="AutoRunButton" Content="A" Width="20" Height="20" Background="DarkGreen" Foreground="White"/>
        </StackPanel>
    </Grid>
</Window>
"@

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
    $Window.Height = $Window.Height + 20                # Increase the window height
    $Window.Width = $Window.Width + 20                  # Increase the window width
    $Window.Left = $Window.Left + 20                    # Move the window to the right
    $MyImage = $Window.FindName("MyImage")              # Get the Image control
    $MyImage.Width += 20                                # Increase the image width
    $MyImage.Height += 20                               # Increase the image height
})

# Zoom Out Functionality
$Window.FindName("ZoomOutButton").Add_Click({
    $MyImage = $Window.FindName("MyImage")
    Write-Host "Width: $($MyImage.Width)"
    $MyImage.Width = [math]::Max($MyImage.Width - 10, 5)
    $MyImage.Height = [math]::Max($MyImage.Height - 10, 5)
})

# Update Location Functionality
$Window.FindName("UpdateLocationButton").Add_Click({
    [System.Windows.MessageBox]::Show("Update Location button clicked.")
})

# Auto Run Functionality
$Window.FindName("AutoRunButton").Add_Click({
    [System.Windows.MessageBox]::Show("Auto Run button clicked.")
})

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
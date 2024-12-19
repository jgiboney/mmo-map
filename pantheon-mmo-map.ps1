$mapSize = 400                                              # Set the size of the map
Add-Type -AssemblyName System.Windows.Forms                 # Load the Windows Forms library
$mapWindow = New-Object System.Windows.Forms.Form           # Create a new form
$mapWindow.Text = "Panthoen MMO Map"                        # Set the form title
$mapWindow.Width = $mapSize                                 # Set the form width
$mapWindow.Height = $mapSize                                # Set the form height
$mapWindow.TopMost = $true                                  # Make the form sit in front of all other windows
$mapWindow.ShowDialog()                                     # Show the form
$mapPictureBox = New-Object System.Windows.Forms.PictureBox # Add a picture box to the form
$mapPictureBox.Width = $mapSize                             # Set the picture box width
$mapPictureBox.Height = $mapSize                            # Set the picture box height
$mapPictureBox.Load()
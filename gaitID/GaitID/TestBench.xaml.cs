using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using TASS;
using WinForms = System.Windows.Forms;

namespace GaitID
{
    /// <summary>
    /// Interaction logic for FeatureID.xaml
    /// </summary>
    public partial class TestBench : Window
    {
        private string fileLoadLocation;
        private List<Double> featuresList;

        // Setup database handler
        DatabaseHandler db = new DatabaseHandler();

        public TestBench()
        {
            InitializeComponent();
        }

        private void BrowseButton_OnClick(object sender, RoutedEventArgs e)
        {
            chooseFileLoadLocation();
        }

        private void chooseFileLoadLocation()
        {
            // Open file browser dialog
            var dialog = new WinForms.OpenFileDialog();
            //dialog.Description = "Select which skeletal data file to identify:";
            WinForms.DialogResult result = dialog.ShowDialog();
            fileLoadLocation = dialog.FileName;
            FileSaveLocationTextBox.Text = fileLoadLocation;
        }

        private void IdentifyButton_OnClick(object sender, RoutedEventArgs e)
        {
            // run tass, save to DB, display results
            TASSDriver tass = new TASSDriver(@"C:\temp\POCM CODE");

            tass.loadSkeleton(fileLoadLocation);

            featuresList = new List<double>(tass.Execute());
        }

        private void CaptureNavButton_OnClick(object sender, RoutedEventArgs e)
        {
            Capture captureWin = new Capture();
            captureWin.Show();
            this.Close();
        }

        private void FeatureNavButton_OnClick(object sender, RoutedEventArgs e)
        {
            FeatureID featureWin = new FeatureID();
            featureWin.Show();
            this.Close();
        }

        private void AccuracyChecked(object sender, RoutedEventArgs e)
        {


        }
    }
}

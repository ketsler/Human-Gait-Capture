using System;
using System.Collections.Generic;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace GaitID
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void goToTraining_Click(object sender, RoutedEventArgs e)
        {
            Training trainingWin = new Training();
            trainingWin.Show();
            this.Close();
        }

        private void goToId_Click(object sender, RoutedEventArgs e)
        {
            Identification idWin = new Identification();
            idWin.Show();
            this.Close();
        }
    }
}

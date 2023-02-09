using System.Diagnostics;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for EME_Header.xaml
    /// </summary>
    public partial class EME_Header : UserControl
    {
        public EME_Header()
        {
            InitializeComponent();
        }

        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo{ FileName = e.Uri.AbsoluteUri, UseShellExecute = true });
            e.Handled = true;
        }
    }
}
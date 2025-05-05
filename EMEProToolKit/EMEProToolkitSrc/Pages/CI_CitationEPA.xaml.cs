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
using System.ComponentModel;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for CI_CitationEPA.xaml
    /// </summary>
    public partial class CI_CitationEPA : EditorPage, INotifyPropertyChanged
    {

        public static readonly DependencyProperty SupressPartiesProperty = DependencyProperty.Register(
           "SupressParties",
           typeof(Boolean),
           typeof(CI_CitationEPA));

        public static readonly DependencyProperty SupressOnlineResourceProperty = DependencyProperty.Register(
           "SupressOnlineResource",
           typeof(Boolean),
           typeof(CI_CitationEPA));

        public Boolean SupressParties
        {
            get { return (Boolean)this.GetValue(SupressPartiesProperty); }
            set { this.SetValue(SupressPartiesProperty, value); }
        }

        public Boolean SupressOnlineResource
        {
            get { return (Boolean)this.GetValue(SupressOnlineResourceProperty); }
            set { this.SetValue(SupressOnlineResourceProperty, value); }
        }

        public CI_CitationEPA()
        {
            InitializeComponent();
        }

    }
}

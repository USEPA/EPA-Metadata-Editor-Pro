using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using ArcGIS.Core.CIM;
using ArcGIS.Core.Data;
using ArcGIS.Core.Geometry;
using ArcGIS.Desktop.Catalog;
using ArcGIS.Desktop.Core;
using ArcGIS.Desktop.Editing;
using ArcGIS.Desktop.Extensions;
using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Framework.Contracts;
using ArcGIS.Desktop.Framework.Dialogs;
using ArcGIS.Desktop.Framework.Threading.Tasks;
using ArcGIS.Desktop.Mapping;

namespace EMEProToolkit
{
    internal class EMEMenu_UpdateContacts : Button
    {
        protected override void OnClick()
        {
            //TODO: Create/reference Async Process for updating contacts
        }
    }
        
    internal class EMEMenu_UpdateThumbnail : Button
    {
        public const string MyStateID = "preview_map_state";
        protected override void OnClick()
        {
            string s = FrameworkApplication.ActiveWindow.ToString();
            //IProjectWindow ipv = ArcGIS.Desktop.Core.IProjectWindow;
            var commandId = @"esri_core_previewCaptureThumbnail";
            var iCommand = FrameworkApplication.GetPlugInWrapper(commandId) as ICommand;
            if (iCommand != null)
            {
                if (iCommand.CanExecute(null)) iCommand.Execute(null);
                System.Windows.MessageBox.Show("it worked?");
            }


            string f = FrameworkApplication.State.ToString();
            System.Windows.MessageBox.Show(s + "   state: "  + f);
            
        }
    }

    internal class EMEMenu_button3 : Button
    {
        protected override void OnClick()
        {
        }
    }

}

﻿#pragma checksum "..\..\..\Pages\ImageAttachement.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "E377B2A34389F1A42485C4AF2408D5BBC1D99B1DC02E2F83B58763CF4BAE6FC6"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using ArcGIS.Desktop.Metadata.Editor;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using ArcGIS.Desktop.Metadata.Editor.Validation;
using EMEProToolkit.Properties;
using System;
using System.Collections;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace EMEProToolkit.Pages {
    
    
    internal partial class MTK_ImageAttachement : ArcGIS.Desktop.Metadata.Editor.Pages.EditorPage, System.Windows.Markup.IComponentConnector {
        
        
        #line 46 "..\..\..\Pages\ImageAttachement.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Image ThumbnailImage;
        
        #line default
        #line hidden
        
        
        #line 50 "..\..\..\Pages\ImageAttachement.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button ImageAttachement_ThumbnailDelete;
        
        #line default
        #line hidden
        
        
        #line 57 "..\..\..\Pages\ImageAttachement.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button ImageAttachement_ThumbnailUpdate;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/EMEProToolkit;component/pages/imageattachement.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\Pages\ImageAttachement.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            
            #line 23 "..\..\..\Pages\ImageAttachement.xaml"
            ((EMEProToolkit.Pages.MTK_ImageAttachement)(target)).Loaded += new System.Windows.RoutedEventHandler(this.FillXml);
            
            #line default
            #line hidden
            return;
            case 2:
            this.ThumbnailImage = ((System.Windows.Controls.Image)(target));
            
            #line 46 "..\..\..\Pages\ImageAttachement.xaml"
            this.ThumbnailImage.Loaded += new System.Windows.RoutedEventHandler(this.LoadedThumbnailImage);
            
            #line default
            #line hidden
            return;
            case 3:
            this.ImageAttachement_ThumbnailDelete = ((System.Windows.Controls.Button)(target));
            
            #line 49 "..\..\..\Pages\ImageAttachement.xaml"
            this.ImageAttachement_ThumbnailDelete.Click += new System.Windows.RoutedEventHandler(this.DeleteThumbnail);
            
            #line default
            #line hidden
            return;
            case 4:
            this.ImageAttachement_ThumbnailUpdate = ((System.Windows.Controls.Button)(target));
            
            #line 56 "..\..\..\Pages\ImageAttachement.xaml"
            this.ImageAttachement_ThumbnailUpdate.Click += new System.Windows.RoutedEventHandler(this.UpdateThumbnail);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
    }
}

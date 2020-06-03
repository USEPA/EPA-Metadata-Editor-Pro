/*
Copyright 2019 Esri
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.​
*/

using System;
using System.Collections;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media.Imaging;
using System.Xml;
using Microsoft.Win32;

using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Metadata;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using System.Windows.Navigation;
using System.Diagnostics;
using System.Windows.Documents;

using System.Collections.Generic;
using System.Windows.Media;
using System.Linq;


namespace EMEProToolkit.Pages
{
    internal class ItemInfoSidebarLabel : ISidebarLabel
    {
        string ISidebarLabel.SidebarLabel
        {
            get { return ItemInfoSidebarLabel.SidebarLabel; }
        }

        public static string SidebarLabel
        {
            get { return EMEProToolkit.Properties.Resources.CFG_LBL_ITEMINFO; }
        }
    }
    /// <summary>
    /// Interaction logic for MTK_ItemInfo.xaml
    /// </summary>
    internal partial class MTK_ItemInfo : EditorPage
    {
        private Image _thumbnailImage = null;
        private bool _isDefault = false;
        private List<string> _listThemeK = new List<string>();

        public MTK_ItemInfo()
        {
            InitializeComponent();
        }
        public override string SidebarLabel
        {
            get { return ItemInfoSidebarLabel.SidebarLabel; }
        }

        public void DeleteThumbnail(object sender, EventArgs e)
        {
            UseDefaultImage();

            var mdModule = FrameworkApplication.FindModule("esri_metadata_module") as IMetadataEditorHost;
            if (mdModule != null)
                mdModule.OnUpdateThumbnail(this);
        }

        public void UpdateThumbnail(object sender, EventArgs e)
        {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.FileName = ""; // Default file name
            dlg.DefaultExt = ".png"; // Default file extension
            dlg.Filter = "Image Files(*.PNG;*.JPG;*.BMP;*.GIF)|*.PNG;*.JPG;*.BMP;*.GIF|All files (*.*)|*.*";

            Nullable<bool> result = dlg.ShowDialog();
            if (true == result)
            {
                if (null != dlg.FileName && 0 < dlg.FileName.Length && File.Exists(dlg.FileName))
                {
                    // loadimage
                    try
                    {
                        // fetch via URL
                        Uri imageUri = new Uri(dlg.FileName);
                        BitmapDecoder bmd = BitmapDecoder.Create(imageUri, BitmapCreateOptions.None, BitmapCacheOption.OnLoad);

                        // reset width
                        ThumbnailImage.Width = double.NaN;

                        // set the source
                        _thumbnailImage.Source = bmd.Frames[0];
                        _isDefault = false;

                        var mdModule = FrameworkApplication.FindModule("esri_metadata_module") as IMetadataEditorHost;
                        if (mdModule != null)
                            mdModule.OnUpdateThumbnail(this);
                    }
                    catch (Exception) { /* noop */ }
                }
            }
        }

        private void CreateThumbnailNode()
        {
            object context = Utils.Utils.GetDataContext(this);
            IEnumerable nodes = Utils.Utils.GetXmlDataContext(context);
            if (null != nodes)
            {
                foreach (XmlNode node in nodes)
                {

                    XmlDataProvider provider = Resources["ThumbnailXml"] as XmlDataProvider;
                    XmlNode owner = (null == node.OwnerDocument) ? node : node.OwnerDocument;
                    Utils.Utils.CopyElements(owner, provider.Document.FirstChild, true, false);

                    break; // paranoid
                }
            }
        }

        private XmlNode GetBinaryThumbnailNode(object sender, bool is_empty_ok)
        {
            object context = Utils.Utils.GetDataContext(sender);
            IEnumerable nodes = Utils.Utils.GetXmlDataContext(context);

            if (null != nodes)
            {
                foreach (XmlNode node in nodes)
                {
                    // fetch base64 image
                    //  <Binary><Thumbnail><Data EsriPropertyType="Picture">... 
                    XmlNode dataNode = node.SelectSingleNode("/metadata/Binary/Thumbnail/Data[@EsriPropertyType=\"Picture\"] | /metadata/Binary/Thumbnail/Data[@EsriPropertyType=\"PictureX\"]");
                    if (null != dataNode && (is_empty_ok || 0 < dataNode.InnerText.Trim().Length))
                        return dataNode;
                }
            }

            return null;
        }

        private void CleanThumbnailNodes(bool cleanAll)
        {
            object context = Utils.Utils.GetDataContext(this);
            IEnumerable nodes = Utils.Utils.GetXmlDataContext(context);

            if (null != nodes)
            {
                foreach (XmlNode node in nodes)
                {
                    // fetch base64 image
                    //  <Binary><Thumbnail><Data EsriPropertyType="Picture">... 
                    XmlNode dataNode = node.SelectSingleNode("/metadata/Binary");
                    if (null != dataNode)
                        dataNode.ParentNode.RemoveChild(dataNode);

                    //if (cleanAll)
                    //{
                    //  dataNode = node.SelectSingleNode("/metadata/Binary/Thumbnail/Data[@EsriPropertyType=\"PictureX\"]");
                    //  if (null != dataNode)
                    //    dataNode.ParentNode.RemoveChild(dataNode);
                    //}
                }
            }
        }

        private void UpdateThumbnail()
        {
            // fetch base64 image
            //  <Binary><Thumbnail><Data EsriPropertyType="Picture">... 
            XmlNode base64imageNode = GetBinaryThumbnailNode(this, false);
            if (null != base64imageNode)
            {
                try
                {
                    // get base64 data and convert
                    string base64 = base64imageNode.InnerText;
                    byte[] base64bytes = System.Convert.FromBase64String(base64);

                    MemoryStream ms = new MemoryStream(base64bytes);
                    BitmapDecoder bmd = BitmapDecoder.Create(ms, BitmapCreateOptions.None, BitmapCacheOption.None);

                    // reset width
                    ThumbnailImage.Width = double.NaN;

                    if (null != _thumbnailImage)
                    {
                        _thumbnailImage.Source = bmd.Frames[0];
                        _isDefault = false;
                    }
                }
                catch (Exception)
                {
                    /* noop */
                }
            }
            else
            {
                // NO THUMBNAIL
                UseDefaultImage();
            }
        }

        private void UseDefaultImage()
        {
            var obj = this.Resources["EmptyImage"];
            if (null != obj)
            {
                BitmapImage emptyImage = obj as BitmapImage;
                _thumbnailImage.Source = emptyImage;
                ThumbnailImage.Width = 32;
            }
            else
            {
                _thumbnailImage.Source = null;
            }

            // now using default
            _isDefault = true;
        }

        override public void CommitChanges()
        {
            if (null == _thumbnailImage.Source || _isDefault)
            {
                CleanThumbnailNodes(true);
                return;
            }

            JpegBitmapEncoder jbe = new JpegBitmapEncoder();
            jbe.Frames.Add(BitmapFrame.Create(_thumbnailImage.Source as BitmapSource));

            MemoryStream ms = new MemoryStream();
            jbe.Save(ms);

            string base64 = System.Convert.ToBase64String(ms.ToArray(), Base64FormattingOptions.InsertLineBreaks);

            // clean nodes
            CleanThumbnailNodes(false);

            // get the insert node
            XmlNode base64imageNode = GetBinaryThumbnailNode(this, true);
            if (null == base64imageNode)
                CreateThumbnailNode();

            // try again:
            base64imageNode = GetBinaryThumbnailNode(this, true);

            if (null != base64imageNode)
            {
                base64imageNode.InnerText = base64;
            }
        }
        public void LoadedThumbnailImage(object sender, RoutedEventArgs e)
        {
            // add me, so I can be called later
            var mdModule = FrameworkApplication.FindModule("esri_metadata_module") as IMetadataEditorHost;
            if (mdModule != null)
                mdModule.AddCommitPage(this);

            _thumbnailImage = sender as Image;
            UpdateThumbnail();
        }
        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri));
            e.Handled = true;
        }
        public List<Control> AllChildren(DependencyObject parent)
        {
            var _List = new List<Control> { };
            for (int i = 0; i < VisualTreeHelper.GetChildrenCount(parent); i++)
            {
                var _Child = VisualTreeHelper.GetChild(parent, i);
                if (_Child is Control)
                    _List.Add(_Child as Control);
                _List.AddRange(AllChildren(_Child));
            }
            return _List;
        }
        private void tbxMdDateSt_Loaded(object sender, RoutedEventArgs e)
        {
            //tbxMdDateSt.Text = DateTime.Now.ToString("yyyyMMdd");
            tbxMdDateSt.Text = DateTime.Now.ToString("yyyy-MM-dd");
            tbxMdDateSt.Focus();
            tbxTopOfPage.Focus();
        }

        private void btnDelSearchTags_Click(object sender, RoutedEventArgs e)
        {
            if (lbxItemDesc.IsVisible == true)
            {
                ListBox liBox = (ListBox)lbxItemDesc;
                foreach (var liBoxItem in liBox.Items)
                {
                    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                    var liBoxChildren = AllChildren(liBoxCont);
                    var liBoxName = "tbxSearchTags";
                    var liBoxCtrl = (TextBox)liBoxChildren.First(c => c.Name == liBoxName);
                    //Add logic to copy to clipboard
                    List<string> listSearchTag = new List<string>();
                    if (liBoxCtrl.Text.Any())
                    {
                        string[] strsearchTag = liBoxCtrl.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string s in strsearchTag)
                        {
                            listSearchTag.Add(s.Trim());
                        }
                    }
                    listSearchTag = listSearchTag.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
                    listSearchTag.Sort();
                    //clear TextBox
                    liBoxCtrl.Text = "";
                    liBoxCtrl.Focus();
                    tbxTopOfPage.Focus();
                }
            }
        }
    }
}


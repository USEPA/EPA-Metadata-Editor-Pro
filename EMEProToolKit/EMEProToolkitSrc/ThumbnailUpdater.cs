﻿using ArcGIS.Core.CIM;
using ArcGIS.Core.Geometry;
using ArcGIS.Desktop.Core;
using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Framework.Dialogs;
using ArcGIS.Desktop.Framework.Threading.Tasks;
using ArcGIS.Desktop.Layouts;
using ArcGIS.Desktop.Mapping;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace EMEProToolkit
{
    public class ThumbnailUpdater
    {
        private string _temppathEme = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\temp\\";
        public void ExportFrameAsync()
        {
            System.IO.Directory.CreateDirectory(_temppathEme);
            string s = FrameworkApplication.ActiveWindow.ToString();
            // int c = Project.Current.SelectedItems.Count;
            foreach (var item in Project.Current.SelectedItems)
            {
                QueuedTask.Run(() =>
                {
                    Guid g = Guid.NewGuid();
                    string tempLayout = "TempLayout";
                    string tempMap = "TempMap";
                    //var newmap = MapFactory.Instance.CreateMap("NewMap", basemap:Basemap.ProjectDefault);
                    // Create a new CIM page
                    CIMPage newPage = new CIMPage();

                    // Add properties

                    newPage.Width = 17;
                    newPage.Height = 11;
                    newPage.Units = LinearUnit.Inches;

                    // Add rulers
                    newPage.ShowRulers = true;
                    newPage.SmallestRulerDivision = 0.5;

                    // Apply the CIM page to a new layout and set name
                    var newLayout = LayoutFactory.Instance.CreateLayout(newPage);
                    newLayout.SetName(tempLayout);

                    Map newMap = MapFactory.Instance.CreateMap(tempMap, MapType.Map, MapViewingMode.Map, Basemap.None);
                    //string url = @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer";
                    Uri uri = new Uri(item.Path);
                    var lyr = LayerFactory.Instance.CreateLayer(uri, newMap);
                    string thumbpath = String.Format(_temppathEme + "{0}_{1}.jpg", lyr.Name, g);
                    MessageBox.Show(thumbpath);
                    

                    // Build a map frame geometry / envelope
                    Coordinate2D ll = new Coordinate2D(1, 0.5);
                    Coordinate2D ur = new Coordinate2D(13, 9);
                    Envelope mapEnv = EnvelopeBuilder.CreateEnvelope(ll, ur);

                    // Create a map frame and add it to the layout
                    MapFrame newMapframe = LayoutElementFactory.Instance.CreateMapFrame(newLayout, mapEnv, newMap);
                    newMapframe.SetName("Map Frame");

                    // Create and set the camera
                    //Camera camera = newMapframe.Camera;
                    //camera.X = -118.465;
                    //camera.Y = 33.988;
                    //camera.Scale = 30000;
                    newMapframe.SetCamera(lyr.QueryExtent());
                    //newMapframe.ZoomTo(lyr.QueryExtent());

                    //Create JPEG format with appropriate settings
                    JPEGFormat JPEG = new JPEGFormat();
                    JPEG.HasWorldFile = false;
                    JPEG.Resolution = 100;
                    JPEG.OutputFileName = thumbpath;
                    //Export MapFrame
                    //Layout lyt = layoutItem.GetLayout(); //Loads and returns the layout associated with a LayoutItem
                    newMapframe.Export(JPEG);
                    LayoutProjectItem layoutItem = Project.Current.GetItems<LayoutProjectItem>().FirstOrDefault(itm => itm.Name.Equals(tempLayout));
                    Project.Current.RemoveItem(Project.Current.GetItems<LayoutProjectItem>().FirstOrDefault(itm => itm.Name.Equals(tempLayout)));
                    Project.Current.RemoveItem(Project.Current.GetItems<MapProjectItem>().FirstOrDefault(itm => itm.Name.Equals(tempMap)));
                    byte[] b = File.ReadAllBytes(thumbpath);
                    //string utf8string = Encoding.UTF8.GetString(b, 0, b.Length);
                    //string asciistring = Encoding.ASCII.GetString(b, 0, b.Length);
                    string b64string = Convert.ToBase64String(b);

                    string xxml = item.GetXml();
                    XmlDocument xmldoc = new XmlDocument();
                    xmldoc.LoadXml(xxml);
                    xmldoc.Save("C:\\Users\\jmaxm\\Desktop\\expxml.xml");
                    //todo create new xml if not exist
                    XmlNode root = xmldoc.DocumentElement;
                    XmlNode thumb = root.SelectSingleNode("descendant::Binary/Thumbnail/Data");
                    if (thumb is null)
                    {
                        if (root.SelectSingleNode("descendant::Binary") is null)
                        {
                            XmlNode binarynode = xmldoc.CreateNode("element", "Binary", "");
                            XmlNode thumbnode = xmldoc.CreateNode("element", "Thumbnail", "");
                            XmlNode datanode = xmldoc.CreateNode("element", "Data", "");
                            ((XmlElement)datanode).SetAttribute("EsriPropertyType", "PictureX");
                            //datanode.Attributes["EsriPropertyType"].Value = "PictureX";
                            datanode.InnerText = b64string;
                            thumbnode.AppendChild(datanode);
                            binarynode.AppendChild(thumbnode);
                            root.AppendChild(binarynode);
                            string newmeta = xmldoc.OuterXml;

                            item.SetXml(newmeta);
                        }
                    }
                    if(thumb != null)
                    {
                        root.SelectSingleNode("descendant::Binary/Thumbnail/Data").InnerText = b64string;
                        //var thumb = xmldoc.GetElementsByTagName("Thumbnail")[0].SelectSingleNode("Data");
                        //thumb.SelectSingleNode("Data")
                        //MessageBox.Show(thumb.InnerXml.ToString());

                        string newmeta = xmldoc.OuterXml;

                        item.SetXml(newmeta);
                        //MessageBox.Show(item.Type);

                    }
                    xmldoc.Save("C:\\Users\\jmaxm\\Desktop\\expxml.xml");
                    File.Delete(thumbpath);

                });
            }
        }    
    }
}

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EMEProToolkit
{
    public class LogOutput
    {
        static string _outputPath =  Environment.GetFolderPath(Environment.SpecialFolder.Personal) + "\\EME_log.txt";
        //public static void Main()
        //{
        //    using (StreamWriter w = File.AppendText("log.txt"))
        //    {
        //        Log("Test1", w);
        //        Log("Test2", w);
        //    }

        //    using (StreamReader r = File.OpenText("log.txt"))
        //    {
        //        DumpLog(r);
        //    }
        //}

        public static void Log(string logMessage)
        {
            Trace.WriteLine("output log: " + _outputPath);
            
            using (StreamWriter w = File.AppendText(_outputPath))
            {
                w.Write("\r\nLog Entry : ");
                w.WriteLine($"{DateTime.Now.ToLongTimeString()} {DateTime.Now.ToLongDateString()}");
                w.WriteLine("  :");
                w.WriteLine($"  :{logMessage}");
                w.WriteLine("-------------------------------");
            }

        }

        public static void DumpLog(StreamReader r)
        {
            string line;
            while ((line = r.ReadLine()) != null)
            {
                Console.WriteLine(line);
            }
        }
    }
}

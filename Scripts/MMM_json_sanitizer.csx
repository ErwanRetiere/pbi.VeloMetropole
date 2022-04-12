using System;
using System.Text;
using System.IO;
using System.Linq;

string FilePath = Args[0];
string FileName = Path.GetFileName(FilePath);

if (File.Exists(FilePath))
{   
    Console.WriteLine("Nettoyage du fichier " + FileName);
    // Preparation du fichier avec Suppression des lignes vides
    var lstLines = File
            .ReadLines(FilePath)
            .Where(line => (line.Length > 1))
            .ToList();

    // Ajout d'un saut de ligne entre deux objets concaténés
    string strPattern = "}{";
    string strPatternExpected = "}\n{";
    var lstCleanedLines = new List<string>();

    foreach (var lstLine in lstLines)
    {
        if (lstLine.Contains(strPattern))
        {
            lstCleanedLines.AddRange(
                String.Join(
                    strPatternExpected,
                    lstLine.Split(strPattern)
                ).Split("\n")
            );
        }
        else
        {
            lstCleanedLines.Add(lstLine);
        }
    }

    // Ajout d'une virgule séparant les objets
    int lastLineIndex = lstCleanedLines.Count -1;
    string lastLine = lstCleanedLines[lastLineIndex];
    lstCleanedLines.RemoveAt(lastLineIndex);
    lstCleanedLines = lstCleanedLines
        .Select(
            lstLine => lstLine + ","
        )
        .ToList();
    lstCleanedLines.Add(lastLine);

    // Ajout du tableau
    lstCleanedLines.Insert(0,"[");
    lstCleanedLines.Add("]");

    // Remplacement du contenu du fichier
    File.WriteAllLines(
        FilePath,
        lstCleanedLines
    ); 
}
else
{
    Console.WriteLine("'" + FileName + "' est inaccessible ou ne correspond pas à un chemin d'accès valide. Argument passé : " + FilePath);
}
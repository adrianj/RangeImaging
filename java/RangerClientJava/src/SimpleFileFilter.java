/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author jongenad
 */
import java.io.*;
public class SimpleFileFilter extends javax.swing.filechooser.FileFilter implements java.io.FileFilter {

    private String description = "All Files *.*";
    private java.util.ArrayList extensions = new java.util.ArrayList();

    public SimpleFileFilter()
    {
        
    }
    public boolean accept(File f)
    {
        // If no extensions have been added, accept all files
        if(extensions.size() == 0)
            return true;
        // accept directories - hopefully this will browse into them?
        if (f.isDirectory()) {
            return true;
        }
        for(int i = 0; i < extensions.size(); i++)
        {
            String ext = (String)(extensions.get(i));
            if(f.getPath().endsWith(ext)) return true;
        }
        return false;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String des)
    {
        description = des;
    }

    public void addExtension(String ext)
    {
        extensions.add(ext);
    }


}

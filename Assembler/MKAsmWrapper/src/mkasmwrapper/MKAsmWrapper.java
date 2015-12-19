/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mkasmwrapper;

import java.io.File;
import java.io.FileNotFoundException;

/**
 *
 * @author mgohde
 */
public class MKAsmWrapper {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException 
    {
        if(args.length<2)
        {
            System.out.println("USAGE: java -jar MKAsmWrapper.jar infile.mka outfile.asm");
        }
        
        else
        {
            Parser p=new Parser(new File(args[0]));
            
            p.parse(new File(args[1]));
        }
    }
    
}

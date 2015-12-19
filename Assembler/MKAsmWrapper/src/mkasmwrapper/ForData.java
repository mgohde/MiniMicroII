/*
 * This contains the data used to generate a for loop.
 */
package mkasmwrapper;

/**
 *
 * @author mgohde
 */
public class ForData 
{
    int counterReg;
    int cmpVal;
    
    boolean compareToReg;
    String label;
    
    public ForData(int newCtr, int newCmp, boolean newCmpReg, String topName)
    {
        counterReg=newCtr;
        cmpVal=newCmp;
        compareToReg=newCmpReg;
        label=topName;
    }
    
}

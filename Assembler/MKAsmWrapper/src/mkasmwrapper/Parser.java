/*
 * This class contains the code necessary to quyickly parse and generate assembly.
 */
package mkasmwrapper;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Scanner;

/**
 *
 * @author mgohde
 */
public class Parser 
{
    private Scanner fileScanner;
    
    public Parser(File inputFile) throws FileNotFoundException
    {
        fileScanner=new Scanner(inputFile);
    }
    
    private int getReg(String tok)
    {
        int tmp;
        ArrayList<ForData> forList=new ArrayList<ForData>();
        
        if(tok.charAt(0)!='r')
        {
            return -1;
        }
        
        tmp=Integer.parseInt(tok.charAt(1)+"");
        
        if(tmp>6||tmp==0)
        {
            return -1;
        }
        
        else
        {
            return tmp;
        }
    }
    
    public void parse(File outputFile) throws FileNotFoundException
    {
        PrintWriter pw=new PrintWriter(outputFile);
        String line, tok;
        Scanner lineScanner;
        ArrayList<ForData> forList=new ArrayList<ForData>();
        int curlblnum;
        
        curlblnum=0;
        
        //Print out a standard header:
        pw.println("xor r0,r0,r0");
        pw.println("xor r1,r1,r1");
        pw.println("xor r2,r2,r2");
        pw.println("xor r3,r3,r3");
        pw.println("xor r4,r4,r4");
        pw.println("xor r5,r5,r5");
        pw.println("xor r6,r6,r6");
        pw.println("ldl $-1");
        pw.println("lsr r0,r7,r0"); //Make the stack pointer reach some of the highest bits of RAM.
        pw.println("ldl #main");
        pw.println("jmp r0,r7,r0");
        
        while(fileScanner.hasNextLine())
        {
            line=fileScanner.nextLine();
            lineScanner=new Scanner(line);
            //tok=lineScanner.next();
            
            if(lineScanner.hasNext())
            {
                tok=lineScanner.next();
                if(tok.charAt(0)=='>') //This is a label. Just include it wholesale:
                {
                    pw.println("nop r0,r0,r0");
                    pw.println(line);
                    pw.println("nop r0,r0,r0"); //This is to work around bugs in the pipeline, assembler, or both.
                }
                
                else if(tok.charAt(0)==';') //It's a comment, ignore the line.
                {
                    //Do nothing! woo!
                }
                
                else if(tok.equals("push"))
                {
                    int reg;
                    reg=getReg(lineScanner.next());
                    
                    pw.println("push r"+reg+",r0,r0");
                }
                
                else if(tok.equals("pop"))
                {
                    int reg;
                    reg=getReg(lineScanner.next());
                    
                    pw.println("pop r0,r0,r"+reg);
                }
                
                else if(tok.equals("sr"))
                {
                    lineScanner.next(); //This is a formality. The next token should be "="
                    tok=lineScanner.next(); 
                    
                    //Check if we're using, one reg, two regs, or a literal:
                    if(tok.charAt(0)!='r')
                    {
                        pw.println("ldl $"+tok);
                        pw.println("lsr r0,r7,r0");
                    }
                    
                    else 
                    {
                        int reg1=getReg(tok);
                        
                        if(lineScanner.hasNext())
                        {
                            int reg2=getReg(lineScanner.next());
                            
                            pw.printf("lsr r%d,r%d,r0\n", reg1, reg2);
                        }
                        
                        else
                        {
                            pw.printf("lsr r0,r%d,r0\n", reg1);
                        }
                    }
                }
                
                else if(tok.equals("string"))
                {
                    pw.println(">"+lineScanner.next()); //print out the string's name.
                    
                    String outString="";
                    pw.print(". ");
                    
                    while(lineScanner.hasNext()) //Get the rest:
                    {
                        outString=outString+" "+lineScanner.next();
                    }
                    
                    pw.print(""+((int)outString.charAt(2))); //First char should be quote.
                    
                    for(int i=3;i<outString.length();i++)
                    {
                        if(outString.charAt(i)!='\"')
                        {
                            pw.print(","+((int)outString.charAt(i)));
                        }
                    }
                    
                    pw.println();
                        
                }
                
                else if(tok.equals("call")) //Intercept calls and make them easier.
                {
                    tok=lineScanner.next();
                    pw.println("nop r0,r0,r0");
                    
                    if(tok.charAt(0)=='#')
                    {
                        pw.println("ldl "+tok);
                        pw.println("call r0,r7,r0");
                    }
                    
                    else if(tok.charAt(0)=='r')
                    {
                        int reg1=getReg(tok);
                        
                        if(lineScanner.hasNext()) //Check if there's a second reg:
                        {
                            int reg2=getReg(lineScanner.next());
                            
                            pw.printf("call r%d,r%d,r0\n", reg1, reg2);
                        }
                        
                        else
                        {
                            pw.printf("call r0,r%d,r0", reg1);
                        }
                    }
                    
                    else //Call a constant:
                    {
                        pw.println("ldl $"+tok);
                        pw.println("call r0,r7,r0");
                    }
                    
                    pw.println("nop r0,r0,r0"); //Until call logic is completely fixed.
                }
                
                else if(tok.equals("const"))
                {
                    pw.println(">"+lineScanner.next()); //Read the const's name
                    
                    pw.println(". "+lineScanner.next()); //As well as the const's raw value.
                }
                
                else if(tok.charAt(0)=='r'&&tok.charAt(1)!='e') //It's doing something with registers. Determine what and generate:
                {
                    int destR;
                    int operand1, operand2;
                    
                    destR=getReg(tok);
                    
                    //Now find out what is needed:
                    tok=lineScanner.next();
                    
                    if(tok.equals("="))
                    {
                        tok=lineScanner.next();
                        System.out.println(tok);
                        
                        //Check if it's loading the value of a constant or other register:
                        if(!lineScanner.hasNext())
                        {
                            if(tok.charAt(0)=='#')
                            {
                                pw.println("ldl "+tok);
                                pw.println("and r7,r7,r"+destR);
                            }
                            
                            else if(tok.charAt(0)=='r')
                            {
                                pw.printf("and %s,%s,r%d\n", tok, tok, destR);
                            }
                            
                            else if(tok.equals("sr")) //Then we're loading from the stack register
                            {
                                pw.printf("ssr r0,r0,r%d\n", destR);
                            }
                            
                            else //Then we're loading a constant
                            {
                                pw.println("ldl $"+tok);
                                pw.println("and r7,r7,r"+destR);
                            }
                        }
                        
                        else
                        {
                            operand1=getReg(tok);
                            String op=lineScanner.next();
                            operand2=getReg(lineScanner.next());
                            
                            //Handle the inversion case.
                            if(tok.equals("~")||tok.equals("!"))
                            {
                                operand1=getReg(op);
                                
                                pw.printf("not r%d,r%d,r%d\n", operand1, operand1, destR);
                            }
                            
                            else if(op.equals("+"))
                            {
                                pw.printf("add r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals("-"))
                            {
                                pw.printf("sub r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals("^"))
                            {
                                pw.printf("xor r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals("|"))
                            {
                                pw.printf("or r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals("&"))
                            {
                                pw.printf("and r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals("<<"))
                            {
                                pw.printf("bsl r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else if(op.equals(">>"))
                            {
                                pw.printf("bsr r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                        }
                        
                    }
                    
                    else if(tok.equals("<-")) //Loads from memory to that reg.
                    {
                        tok=lineScanner.next();
                        
                        if(tok.charAt(0)!='r') //Then it's a fixed address.
                        {
                            if(tok.charAt(0)=='#') //Trying to load a label
                            {
                                pw.println("ldl "+tok);
                            }
                            
                            else
                            {
                                pw.println("ldl $"+tok);
                            }
                            
                            pw.println("load r0,r7,r"+destR);
                        }
                        
                        else
                        {
                            operand1=getReg(tok);
                            
                            if(lineScanner.hasNext())
                            {
                                operand2=getReg(tok);
                                
                                pw.printf("load r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else
                            {
                                pw.printf("load r0,r%d,r%d\n", operand1, destR);
                            }
                        }
                        
                    }
                    
                    else if(tok.equals("->")) //Stores from that reg to memory.
                    {
                        tok=lineScanner.next();
                        
                        if(tok.charAt(0)!='r') //Then it's a fixed address.
                        {
                            if(tok.charAt(0)=='#') //Trying to load a label
                            {
                                pw.println("ldl "+tok);
                            }
                            
                            else
                            {
                                pw.println("ldl $"+tok);
                            }
                            
                            pw.println("store r0,r7,r"+destR);
                        }
                        
                        else
                        {
                            operand1=getReg(tok);
                            
                            if(lineScanner.hasNext())
                            {
                                operand2=getReg(tok);
                                
                                pw.printf("store r%d,r%d,r%d\n", operand1, operand2, destR);
                            }
                            
                            else
                            {
                                pw.printf("store r0,r%d,r%d\n", operand1, destR);
                            }
                        }
                    }
                    
                }
                
                else if(tok.equals("for"))
                {
                    ForData newFor;
                    int ctrReg;
                    int toVal;
                    boolean toValReg;
                    toValReg=true;
                    
                    ctrReg=getReg(lineScanner.next());
                    lineScanner.next(); //Delete the "TO"
                    tok=lineScanner.next(); //Get the exit condition.
                    
                    toVal=getReg(tok);
                    
                    if(toVal==-1)
                    {
                        toVal=Integer.parseInt(tok);
                        toValReg=false;
                    }
                    
                    if(ctrReg==-1)
                    {
                        System.out.println("ERROR: For loop lacks proper counter register assignment.");
                        System.out.println("Line: "+line);
                        System.exit(1);
                    }
                    
                    forList.add(new ForData(ctrReg, toVal, toValReg, "loop"+curlblnum));
                    
                    pw.println(">loop"+curlblnum); //Start the loop off. 
                    
                    curlblnum++;
                }
                
                else if(tok.equals("endfor"))
                {
                    ForData d=forList.remove((forList.size()-1)); //Pop the last value off of the for loop stack.
                    
                    //Compare the loop counter against the set value:
                    if(d.compareToReg)
                    {
                        pw.printf("cmp r%d,r%d,r0\n", d.counterReg, d.cmpVal);
                    }
                    
                    else
                    {
                        pw.println("ldl $"+d.cmpVal);
                        pw.printf("cmp r%d,r%d,r0\n", d.counterReg, 7);
                    }
                    
                    //Now generate the comparison jump:
                    pw.println("ldl #"+"loopend"+curlblnum);
                    pw.println("je r0,r7,r0");
                    
                    //Increment the loop counter:
                    pw.println("ldl $1");
                    pw.printf("add r7,r%d,r%d\n", d.counterReg, d.counterReg);
                    pw.println("ldl #"+d.label);
                    pw.println("jmp r0,r7,r0");
                    pw.println("nop r0,r0,r0"); //This is to work around a minor fault in the assembler.
                    
                    //Add the out of loop area:
                    pw.println(">loopend"+curlblnum);
                    curlblnum++;
                }
                
                else if(tok.equals("goto")) //This generates a jump
                {
                    tok=lineScanner.next(); //This is the label to go to.
                    pw.println("ldl "+tok);
                    pw.println("jmp r0,r7,r0");
                    pw.println("nop r0,r0,r0");
                }
                
                else if(tok.equals("gotoequal")) //Compares and jumps:
                {
                    int r1, r2;
                    String dest;
                    r1=getReg(lineScanner.next());
                    r2=getReg(lineScanner.next());
                    dest=lineScanner.next();
                    
                    pw.printf("cmp r%d,r%d,r0\n", r1, r2);
                    pw.println("ldl "+dest);
                    pw.println("je r0,r7,r0");
                    pw.println("nop r0,r0,r0");
                }
                
                else if(tok.equals("gotoless"))
                {
                    int r1, r2;
                    String dest;
                    r1=getReg(lineScanner.next());
                    r2=getReg(lineScanner.next());
                    dest=lineScanner.next();
                    
                    pw.printf("cmp r%d,r%d,r0\n", r1, r2);
                    pw.println("ldl "+dest);
                    pw.println("jn r0,r7,r0");
                    pw.println("nop r0,r0,r0");
                }
                
                else if(tok.equals("gotogreater"))
                {
                    int r1, r2;
                    String dest;
                    r1=getReg(lineScanner.next());
                    r2=getReg(lineScanner.next());
                    dest=lineScanner.next();
                    
                    pw.printf("cmp r%d,r%d,r0\n", r1, r2);
                    pw.println("ldl "+dest);
                    pw.println("jp r0,r7,r0");
                    pw.println("nop r0,r0,r0");
                }
                
                else
                {
                    pw.println(line); //Just include any normal assembly statements.
                }
            }
        }
        
        pw.flush();
        
    }
}

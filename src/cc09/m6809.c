/* 

  monitor source code for 6809 MICROPROCRSSOR KT 2017 
  compiled with cc09 c compiler and as9 assembler
  monitor source code was written by Wichit Sirichote, wichit.sirichote@gmail.com

  cc09>cc09 mon6809.c mon6809.asm -z
  cc09>as9 mon6809.asm

  The object file is Motorola S19 record

*/


#include startRAM.h



int i;
int j;
char n;
char k;
char u,q,o,key;
char x;
char hit;


int temp,temp16;
int PC, save_PC;

char state;

int USER_PC,USER_U,USER_X,SAVE_SP;
int USER_Y;

char USER_A,USER_B,USER_P,USER_DP;

int timeout;
char buffer[6];	
  
char *gpio1;
char *port2;
char *port1;
char *port0;
char *dptr;

#define  AS9 1
#include startup.h

#define ACIAPORT  0xA000

#define LCD_cwr 0x9000;
#define LCD_dwr 0x9001;
#define LCD_crd 0x9002;
#define LCD_drd 0x9003;

#define BUSY 0x80


#const

char convert[16]= {0xBD,0x30,0x9B,0xBA,0x36,0xAE,0xAF,0x38,
                  0xBF,0xBE,0x3F,0xA7,0x8D,0xB3,0x8F,0x0F};


#code

/*       LCD driver   */

LcdReady()
{
   timeout=0;
    dptr = LCD_crd;
    while((*dptr&0x80==1) && (timeout<200))
    ++timeout; 
}

clr_screen()
{
    LcdReady();
	dptr = LCD_cwr;
    *dptr=0x01;
}


goto_xy(x,y)
int x, y;
{
    LcdReady();
	dptr = LCD_cwr;
    
	if(y==0) *dptr=0x80+x;
    if(y==1) *dptr=0xC0+x; 
    if(y==2) *dptr=0x94+x; 
    if(y==3) *dptr=0xd4+x;
    
}


InitLcd()
{
    LcdReady();
	dptr = LCD_cwr;
    *dptr=0x38;
    LcdReady();
    dptr = LCD_cwr;
    *dptr=0x0c;
    clr_screen();
    goto_xy(0,0);
}


PutLCD(str)

char *str;
{   
    char i;
    for (i=0; str[i] != '\0'; i++)
	{
    LcdReady();
	dptr = LCD_dwr;
    *dptr=str[i];
    }


}

putch_lcd(ch)
char ch;

{
    LcdReady();
	dptr= LCD_dwr;
    *dptr=ch;
}




/* return internal code hex keys and function keys  */

key_code(n)
char n;
{
	char d;
	if(n == 0x16) return 0;
	if(n == 0x21) return 1;
	if(n == 0x1b) return 2;
	if(n == 0x15) return 3;
	if(n == 0x1c) return 4;
	if(n == 0x20) return 5;
	if(n == 0x1a) return 6;
	if(n == 0x14) return 7;
	if(n == 0x22) return 8;
	if(n == 0x1f) return 9;
	if(n == 0x19) return 0xa;
	if(n == 0x13) return 0xb;
	if(n == 3) return 0xc;
	if(n == 0x1e) return 0xd;
	if(n == 0x18) return 0xe;
	if(n == 0x12) return 0xf;
	
	if(n == 0xc) return 0x10;
	if(n == 0xd) return 0x11;
	if(n == 0xe) return 0x12;
	if(n == 0xf) return 0x13;

	if(n == 6) return 0x14;
	if(n == 7) return 0x15;
	if(n == 8) return 0x16;
	if(n == 9) return 0x17;

	if(n == 0) return 0x18;
	if(n == 1) return 0x19;
	if(n == 2) return 0x1a;
	if(n == 0x23) return 0x1b;

    if(n == 0x13) return 0x1c;
	if(n == 0x1d) return 0x1d;
	if(n == 0x17) return 0x1e;
	if(n == 0x10) return 0x1f;


	
	
    
}

delay_num1()
{
  temp=0;
  temp=0;
}

delay_ms(w)
int w;
{
  for( n = 0; n < w; n++)
	  continue;

}



scan()
{
	char key_pressed;

    k = 1;
	u = 0;
	key = -1; 
	q = 0; 

   for(i=0; i<6; i++)
   {
     *port1 = ~k;
	 
	 *port2 = buffer[i];
	 
	 if(buffer[i] != 0x30 && buffer[i] != 0x38 && buffer[i] != 0x70) delay_ms(2);
	 else delay_num1(); 
	 
	 *port2 = 0;
	  
	  delay_ms(1);
      
	  o= *port0; 

	 for(n=0; n<6; n++) 
	 {
	   if((o&1)==0)
		 {key=q;
      
	  /*    *gpio1=key;   */

		 }
	   
	   else q++;
	   o = o >> 1;
	 }
 
	  k = k << 1;
  }

   o = *port0;
  
  if((o&0x40)==0) key=0x23; 

     key_pressed=key;

	 return key_pressed;
    
}


dot_address()
{
 buffer[0]=buffer[0]&~0x40;
	buffer[1]=buffer[1]&~0x40;

	
		buffer[2]=buffer[2]|0x40;
			buffer[3]=buffer[3]|0x40;
				buffer[4]=buffer[4]|0x40;
				buffer[5]=buffer[5]|0x40;
			
}


dot_data()
{

 	buffer[0]=buffer[0]|0x40;
	buffer[1]=buffer[1]|0x40;

	buffer[2]=buffer[2]&~0x40;
			buffer[3]=buffer[3]&~0x40;
				buffer[4]=buffer[4]&~0x40;
				buffer[5]=buffer[5]&~0x40;
				
}

hex4(h)
int h;
{
    temp16 = h;
	buffer[2]= convert[temp16&0xf];
	temp16>>=4;
	buffer[3]= convert[temp16&0xf];
	temp16>>=4;
	buffer[4]=convert[temp16&0xf];
	temp16>>=4;
	buffer[5]=convert[temp16&0xf];
}


address_display()
{

	temp16 = PC;

	hex4(temp16);
	/*
	buffer[2]= convert[temp16&0xf];
	temp16>>=4;
	buffer[3]= convert[temp16&0xf];
	temp16>>=4;
	buffer[4]=convert[temp16&0xf];
	temp16>>=4;
	buffer[5]=convert[temp16&0xf];
	*/

}

data_display()
{
    dptr =PC;

	n = *dptr;

	buffer[0]= convert[n&0xf];
	n = n>>4;
	buffer[1]=convert[n&0xf];
}

read_memory()
{
    address_display();
	data_display();
}


key_address()
{
   
	
	state = 1;
	
  	read_memory();


    dot_address();
	hit=0;

	

	
 }

key_data()
{
	
	read_memory();
    dot_data();
    hit=0;
	state=2;

}

key_plus()
{
      
     if(state==1 || state==2 || state==4 || state==5 || state==6)
     {
       PC++;
       read_memory();
	   key_data();
	  }
}

key_minus()
{
   if(state==1 | state ==2)
   {
    PC--;
    read_memory();
	key_data();
   }
}

data_hex()
{
   
   dptr = PC;
	x = *dptr;
	if(hit==0) x=0;
	{
	 hit =1;
	 x = x << 4;
	 x = x|key;

	 *dptr = x;

	 read_memory();

     dot_data();
	}
}

key_PC()
{
     PC=save_PC;
	 key_data();
}

hex_address()
{
    if(hit==0) PC=0;
	{
	   hit=1;

	   PC<<=4;
	   PC |= key;
	   read_memory();
	   dot_address();
	}
}


key_go(){
#asm
   STS SAVE_SP   
   LDU USER_U   

   LDD PC
   PSHS D

   LDA USER_P
   TFR A,CC
   LDA USER_DP
   TFR A,DP

   LDX USER_X
   LDY USER_Y
   LDB USER_B
   LDA USER_A
   RTS
#endasm

}


key_reg()
{
   buffer[7]=0;
   buffer[6]=0;
   buffer[5]= 0x03;
   buffer[4]= 0x8F;
   buffer[3]= 0xad;
   buffer[2]=0;
   buffer[1]=0;
   buffer[0]=0;

   state = 3;    /* register display state = 3 with hex key */

}


acca()
{
	
    n = USER_A;

	buffer[2]= convert[n&0xf];
	n = n>>4;
	buffer[3]=convert[n&0xf];
	buffer[4]=0;
	buffer[5]=0;
	buffer[1]=0;
	buffer[0]=0x3f;
}

accb()
{
	
    n = USER_B;

	buffer[2]= convert[n&0xf];
	n = n>>4;
	buffer[3]=convert[n&0xf];
	buffer[4]=0;
	buffer[5]=0;
	buffer[1]=0;
	buffer[0]=0xa7;
}

ab()
{
	
    n = USER_B;

	buffer[2]= convert[n&0xf];
	n = n>>4;
	buffer[3]=convert[n&0xf];
	
	n = USER_A;
    buffer[4]= convert[n&0xf];
	n = n>>4;
	buffer[5]=convert[n&0xf];

	
	buffer[1]=0x3f;
	buffer[0]=0xa7;
}

reg_x()
{
	temp16 = USER_X;
	
	hex4(temp16);
	

	buffer[1] = 0;
	buffer[0] = 0x13;

}

reg_y()
{
	temp16 = USER_Y;
     hex4(temp16);
	

	buffer[1] = 0;
	buffer[0] = 0xb6;

}

reg_u()
{
    temp16 = USER_U;
	hex4(temp16);
	

	buffer[1] = 0;
	buffer[0] = 0xb5;

}

reg_s()
{

	temp16 = SAVE_SP;
	hex4(temp16);


	buffer[1] = 0;
	buffer[0] = 0xae;
}

reg_dp()
{

	n = USER_DP;

	buffer[2]= convert[n&0xf];
	n = n>>4;
	buffer[3]=convert[n&0xf];
	buffer[4]=0;
	buffer[5]=0;
	buffer[1]=0xb3;
	buffer[0]=0x1F;
}

low_cc()
{
  n = USER_P;
  if(n&1) buffer[2]=0x30; else buffer[2]=0xbd;
  if(n&2) buffer[3]=0x30; else buffer[3]=0xbd;
  if(n&4) buffer[4]=0x30; else buffer[4]=0xbd;
  if(n&8) buffer[5]=0x30; else buffer[5]=0xbd;
    
	buffer[1]=0x8d;
	buffer[0]=0x85;
}

hi_cc()
{
  n = USER_P;
  if(n&0x10) buffer[2]=0x30; else buffer[2]=0xbd;
  if(n&0x20) buffer[3]=0x30; else buffer[3]=0xbd;
  if(n&0x40) buffer[4]=0x30; else buffer[4]=0xbd;
  if(n&0x80) buffer[5]=0x30; else buffer[5]=0xbd;
    
	buffer[1]=0x8d;
	buffer[0]=0x37;

}



reg_display()
{

   if(key==0) acca();
   if(key==1) accb();
   if(key==2) ab();
   if(key==6) reg_x();
   if(key==7) reg_y();
   if(key==9) reg_u();
   if(key==10) reg_s();
   if(key==8) reg_dp();
   if(key==5) low_cc();
   if(key==4) hi_cc();

}

/* insert byte and shift 512 bytes down */

insert()
{
	dptr=PC;
    for(j=512; j>0; j--)
	{
	 *(dptr+j)=*(dptr+j-1);
	}
	*(dptr+1)=0;  /* insert next byte */
	PC++;
    read_memory();
	state=2;
}


/* delete current byte and shift 512 bytes up */

cut_byte()
{
  	dptr=PC;
    for(j=0; j<512; j++)
	{
	 *(dptr+j)=*(dptr+j+1);
	}
    read_memory();
	state=2;
}



key_exe()
{ 

 if( key>15)
	{
  if(key==0x13) key_address();
  if(key==0x12) key_data();
  if(key==0x17) key_plus();
  if (key==0x16) key_minus();
  if (key==0x10) key_PC();
  if (key==0x1b) key_go();
  if (key==0x11) key_reg();
  if (key==0x18) insert();
  if (key==0x19) cut_byte();
  	}

 else
	{

  if(state==1) hex_address();
  if(state==2) data_hex();
  if(state==3) reg_display();



	}

}








scan1()
{
    while( scan() != -1)
      continue;
   delay_ms(3);

   while(scan() == -1)
      continue;
   delay_ms(3);
  
   	key = scan();

	key = key_code(key); 

   *gpio1 = key;

   key_exe();

  
}











/* ACIA with 4.9152MHz CPU XTAL, bit rate is 19200, 8n1 */

initacia()      
{
        char dummy, *acia, reset, baudrate;
        acia = ACIAPORT;
        baudrate = 0x16;
        reset = 3;
        *(acia) = reset;
        *(acia) = baudrate;
        dummy = *(acia+1);      /*clear RBR*/
}

putchar(ch)
char ch;
{
        int loop;
        char *acia;
        acia = ACIAPORT;
        while( ((*acia) & 0x02) == 0)    /* wait on TDRE */
          continue;
        *(acia+1) = ch;
      
}

puts(s)  
char *s;
{
        /* compiler handles \\ \' \n \r \f \b \t */
        while( *s ) {
               putchar(*s);
               s++;
        }
       
}


initreg()
{
	 PC = 0x200;
   save_PC = 0x200;
   USER_U = 0x7F00;
   #asm
	   TFR CC,A
	   STA USER_P
   #endasm  
	   
   gpio1 = 0x8000;
   port2 = 0x8003;
   port1 = 0x8002;
   port0 = 0x8001;

}


main()
{
   delay_ms(100);  /* power up delay */

  initacia();

   puts("\r\n6809 MICRIPROCESSOR KIT 2017");
  
   InitLcd();
   PutLCD("  6809 MICROPROCESSOR");
   goto_xy(0,1);
   PutLCD("32kB RAM UART LCD");
   
   *gpio1=0;
     
   buffer[5]= convert[6];
   buffer[4]= convert[8];
   buffer[3]= convert[0];
   buffer[2]= convert[9];
   buffer[1]=0;
   buffer[0]=0;
   
	 initreg();

    while(1)
	{
      
       scan1();
	   
	  
	}

}








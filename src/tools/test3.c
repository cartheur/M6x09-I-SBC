#include startRAM.h

int i;
int j;
char n;
char k;
char u,q,o,key;
char x;
char hit, positive;
char flag;
char tick;
int bcc;
int save_bcc, bcc_error;


int temp,temp16;

int PC, save_PC;
int num, start, end, desti;

int t;

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
char *dptr2;


#define  AS9 1
#include startup.h

#define ACIAPORT  0xA000

#define LCD_cwr 0x9000
#define LCD_dwr 0x9001
#define LCD_crd 0x9002
#define LCD_drd 0x9003

#define BUSY 0x80

#define xon 17
#define xoff 19

#const

char convert[16]= {0xBD,0x30,0x9B,0xBA,0x36,0xAE,0xAF,0x38,
                  0xBF,0xBE,0x3F,0xA7,0x8D,0xB3,0x8F,0x0F};

char cold_msg[12]= {0,0,0,0,0,0,0xae,0xbf,0xbd,0xbe,0,0};


#code

/*   LCD driver   */

LcdReady()
{
   timeout=0;
    dptr = LCD_crd;
  
   while((*dptr&0x80==1) && (timeout<500))
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
    switch(y)
	{
	case 0: *dptr=0x80+x; break;
    case 1: *dptr=0xC0+x; break; 
    case 2: *dptr=0x94+x; break; 
    case 3: *dptr=0xd4+x; break;
    }
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
	delay_ms(100);
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
	if(n == 0x24) return 0x1b;

    if(n == 0x23) return 0x1c;
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
      
	

		 }
	   
	   else q++;
	   o = o >> 1;
	 }
 
	  k = k << 1;
  }

   o = *port0;
  
  if((o&0x40)==0) key=0x24; 

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
	

}

data_display()
{
    dptr =PC;

	n = *dptr;

	buffer[0]= convert[n&0xf];
	n = n>>4;
	buffer[1]=convert[n&0xf];
	dot_data();

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
      
     if(state==1 || state==2)
     {
       PC++;
       read_memory();
	   key_data();
	  }
	  if(state==4)
	{
	   start=num;
       hit =0;
	   positive=1;


	}

	if(state==5)
	{

     state=6;
	 start = num;
	 hit=0;
	 buffer[0]=0x8f;  /* end cursor */
     return;
	
	}
	

    if(state==6)
	{

     state=7;
	 end = num;
	 hit=0;
	 buffer[0]=0xb3;  /* destination cursor */
	 
	 if(end <= start) print_error();

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
   
   if(state==4)
	{
	   start=num;
       hit =0;
       positive=0;
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

print_error()
{
  
  buffer[5]= 0x8f;
  buffer[4]= 3;
  buffer[3]=3;
  buffer[2]=0;
  buffer[1]=0;
  buffer[0]=0;
  state=0;
}


key_go(){

	if(state==1 || state==2)
	{
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
   
   if(state==4)
	{
      
	   desti = num;
	  
	  if(positive==0) start= start-desti;
	  	  else start = start+desti;

	   hex4(start);
	   hit=0;

	}

	if(state==7)
	{
		desti = num;
		temp = end-start;
		dptr = start;
		dptr2 = desti;
	
		for(i=0; i<temp; i++)
		{
			*(dptr2+i)=*(dptr+i);
		}	
		PC = desti;
        read_memory();
        dot_data();
		state=2;



	}


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

  switch(key)
	{
   case 0: acca(); break;
   case 1: accb(); break;
   case 2: ab(); break;
   case 6: reg_x(); break;
   case 7: reg_y(); break;
   case 9: reg_u(); break;
   case 10: reg_s(); break;
   case 8: reg_dp(); break;
   case 5: low_cc(); break;
   case 4: hi_cc(); break;
    }
}

/* insert byte and shift 512 bytes down */

insert()
{
	if(state==1 || state==2)
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
}


/* delete current byte and shift 512 bytes up */

cut_byte()
{
   if(state==1 || state==2)
	{

  	dptr=PC;
    for(j=0; j<512; j++)
	{
	 *(dptr+j)=*(dptr+j+1);
	}
    read_memory();
	state=2;
	}
}

key_test()
{
	/* clear I bit to enable irq */
	  #asm
		andcc #$ef
      #endasm
     t=0;
	  buffer[0]=0;buffer[1]=0;

  while(1)
	{
	 
	  while(tick<10)
		  scan();
		tick=0;
		hex4(t);
     	*gpio1 = t;
		t++;
    
	
	}

}

clear_buffer()
{
	for(i=0; i<6; i++)
		*(buffer+i)=0;
}

key_cal()
{
	state = 4;

    clear_buffer();
    buffer[2]= 0xbd;
	start=0;
	desti=0;
	/*buffer[1] = 0x8d;
    buffer[0] = 0x85;
	*/
	hit = 0;

}



enter_num()
{
   if(hit==0) num=0;
	{
	   hit=1;

	   num<<=4;
	   num |= key;
	   hex4(num);
	  
	}
}

key_copy()
{
		state=5;
		hit=0;
		clear_buffer();
        buffer[2]= 0xbd;
		
		buffer[0]=0xae;
		buffer[1]=0;
}




key_exe()
{ 

   if(flag==0) beep();
  
  
 if( key>15)
	{

 switch(key)
		{
  case 0x13: key_address(); break;
  case 0x12: key_data(); break;
  case 0x17: key_plus(); break;
  case 0x16: key_minus(); break;
  case 0x10: key_PC(); break;
  case 0x1b: key_go(); break;
  case 0x11: key_reg(); break;
  case 0x18: insert(); break;
  case 0x19: cut_byte(); break;
  case 0x15: flag = flag^1; break;
  case 0x1a: key_test(); break;
  case 0x1d: key_cal(); break;
  case 0x1c: key_copy(); break;
  case 0x1e: key_dump(); break;
  case 0x1f: key_load(); break;

/*  case 0x14: key_user(); break;  available for user key */

		}
  	}

 else
	{

  switch(state)
		{
  case 1: hex_address(); break;
  case 2: data_hex(); break;
  case 3: reg_display(); break;
  case 4: enter_num(); break;
  case 5: enter_num(); break;
  case 6: enter_num(); break;
  case 7: enter_num(); break;

		}

	}

}


delay_beep()
{
   for(j=0; j<2; j++)
   continue;
}


beep()
{
	char x;
	
   *port2=0;   

   for(x=0; x<60; x++)
   {
   *port1 = ~0x80;
    delay_beep();
   *port1 = 0xff;
    delay_beep();
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
        char *acia;
        acia = ACIAPORT;
        while( ((*acia) & 0x02) == 0)    /* wait on TDRE */
          continue;
        *(acia+1) = ch;
      
}

puts(s)  
char *s;
{
        while( *s ) {
               putchar(*s);
               s++;
        }
       
}

getchar()
{
	char ch;
	char *acia;
  	
	acia=ACIAPORT;
	while((*acia&1)==0)
		continue;
	
	   ch = *(acia+1);           /*read 0xA001*/

	   return ch;
}

newline()
{
	putchar(0x0a);
	putchar(0x0d);
}

send_hex(n)
char n;
{
   k = n>>4;
   k = k&0xf;

   if (k>9) putchar(k+0x37); else putchar(k+0x30);
   k= n&0xf;
   if (k>9) putchar(k+0x37); else putchar(k+0x30);
}

send_word_hex(n)
int n;
{
   temp16 = n>>8;
   k = temp16&0xff;
   send_hex(k);
   k = n&0xff;
   send_hex(k);
}



key_dump()
{
   int j,p;

   dptr = PC;

   for(j=0; j<16; j++)
   {
     newline();
     send_word_hex(dptr);
     putchar(':');
        for(p=0; p<16; p++)
        {

         send_hex(*(dptr+p));
         putchar(0x20);
         }

        putchar(0x20);

        for (p=0; p<16; p++)
        {
          q=*(dptr+p);
         if(q >= 0x20 && q < 0x80) putchar(q); 
          else putchar('.');
        
        }


         dptr+=16;
   }
   newline();
   PC = dptr;   
   key_address(); 
}

nibble2hex(c)
char c;
{
	char n;
  if(c<0x40) return (c-0x30);
  else return (c-0x37);
}

gethex()
{
  int a,b;

  a = getchar2();
  b = getchar2();
  
  a = nibble2hex(a)<<4;
  b = nibble2hex(b);
  a = a|b;
  bcc = bcc+a;  /* compute check sum */
  
  return (a);
}

get16bitaddress()
{
  int load_address;

  load_address =0;

  load_address |= gethex();
  load_address <<=8;
  load_address |= gethex();

  return load_address;
}


read_record1()
{
   
   char x;
   char byte_count;

   int address16bit;

   bcc =0;

   byte_count = gethex()-3;  /* only data record */

   address16bit = get16bitaddress();

   dptr = address16bit;
  for(x=0; x<byte_count; x++)
   {
    *(dptr+x) = gethex();
   }

   bcc = ~bcc;   /* one's complement */
 
 

    save_bcc=  bcc&0xff;

  if(save_bcc != gethex()) bcc_error=1;

}

get_s_record()
{
   end =0;
   bcc_error=0;
     

   while(end==0)
   {
	
 
	 while(getchar2() != 'S')
      continue;

      switch(getchar2()) /* get record type */
      {
       case '0': end=0; break;
       case '1': read_record1(); break;
       case '5': end=1; break;
       case '9': end=1; break;
      }
    }

   newline();
   if(bcc_error) puts("check sum errors!");
   else puts("0 error...");

    key_data();
}

key_load()
{
  newline();
  puts("Load Motorola s-record");

   get_s_record();  /* accept only S1 record */

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

wait1s()
{
	  #asm
		andcc #$ef
      #endasm
		  while(tick<100);
	  tick=0;
}

/* hardware flow control with RTS/CTS */

getchar2()
{
	char ch;
	char *acia;
  	
	acia=ACIAPORT;
	
	*acia = 0x16; /* enable receiving */
	
	while((*acia&1)==0)
		;
    
	 *acia = 0x56; /* stop sending */
	
	
	   ch = *(acia+1);           /*read 0xA001*/

	   *gpio1=ch;   

	   return ch;
}
 

main()
{
    initreg();

    
	*gpio1=0;

	*port2=0;
	*port1=0xff;

	flag=0;
   
   initacia();

   newline();
   puts("6809 MICROPROCESSOR KIT 2020");
   
   InitLcd(); 
   InitLcd();

   PutLCD("6809 MICROPROCESSOR");
   goto_xy(0,1);
   PutLCD("32kB RAM UART LCD");
  
   buffer[5]= convert[6];
   buffer[4]= convert[8];
   buffer[3]= convert[0];
   buffer[2]= convert[9];
   buffer[1]=0;
   buffer[0]=0;
   
	
    while(1)
	{
       scan1();  
	}

}

/* 

  monitor source code for 6809 MICROPROCRSSOR KIT 2020 
  compiled with cc09 c compiler and as9 assembler
  monitor source code was written by Wichit Sirichote, wichit.sirichote@gmail.com

  cc09>cc09 file.c file.asm -z
  cc09>as9 file.asm

  The object file is Motorola S19 record

  more update and technical information, kswichit.com/6809/6809.htm 

*/








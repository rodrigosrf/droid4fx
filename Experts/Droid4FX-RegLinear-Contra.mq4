//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico = 2001;
input double Lote      = 0.01;
input int    Periodo   = 21;
input int    Distancia = 50;

string versao = "Versão: 1.0";

datetime dtCalculado = 0;
bool     blOperBuy   = false;
bool     blOperSell  = false;
int      seqBuy      = 0;
int      seqSell     = 0;

int OnInit()
{
   blOperBuy  = false;
   blOperSell = false;
   seqBuy     = 0;
   seqSell    = 0;   

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   blOperBuy   = false;
   blOperSell  = false;
   seqBuy      = 0;
   seqSell     = 0;   
}

void OnTick()
{

   double valorEsq = 0;
   double valorDir = 0;   
   int    vTicket  = 0;
   
   if(Volume[0]<5) return;
   
   CalcRegLinear(Periodo, 0, valorEsq, valorDir);

   blOperBuy   = false;
   blOperSell  = false;

   if(dtCalculado!=Time[0])
   {
      dtCalculado = Time[0];
   
      if(valorEsq<valorDir)
      {
         seqBuy++; 
         seqSell = 0;  
      }
      else if(valorEsq>valorDir)
      {
         seqSell++;
         seqBuy = 0;
      }   
   }

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol)
            if(OrderMagicNumber()==NumMagico)
            {
               if( (OrderType()==OP_BUY && Close[0]<=valorDir) ||
                   (OrderType()==OP_SELL && Close[0]>=valorDir) )
               {
                  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Yellow))
                     Print("Erro ao fechar ordem. Ticket: " + IntegerToString(OrderTicket()));
               }      
               else if(OrderType()==OP_BUY)
               {
                  blOperBuy = true;
               }
               else if(OrderType()==OP_SELL)
               {
                  blOperSell = true;               
               }               
            }   
   }
 
   if(!blOperBuy && !blOperSell)
   {
      if(valorEsq<valorDir && Close[0]>=(valorDir + (Distancia * 0.0001))
         && seqSell>=Periodo)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_SELL, 
                     Lote, 
                     Bid, 
                     3, 0, 0, "", NumMagico, 0, Blue);         
      }
      else if(valorEsq>valorDir && Close[0]<=(valorDir - (Distancia * 0.0001))
         && seqBuy>=Periodo)   
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_BUY, 
                     Lote, 
                     Ask, 
                     3, 0, 0, "", NumMagico, 0, Blue);
      }
   }

}

void CalcRegLinear(
                  int pPeriodo,
                  int pIndiceBarra,
                  double &pVlrEsq,
                  double &pVlrDir)
{

   double a     = 0,
          b     = 0,
          c     = 0,
          sumy  = 0,
          sumx  = 0,
          sumxy = 0,
          sumx2 = 0;
          
   int i = 0, 
       x = 0;

   pVlrEsq = 0;
   pVlrDir = 0;

   if(pPeriodo<=1)
   {
      Print("Periodo não pode ser menor que 2!");
      return;   
   }

   x = 0;
   while(x<pPeriodo)
   {
      i = (x + pIndiceBarra); 

      sumy+=Close[i];
      sumxy+=Close[i]*i;
      sumx+=i;
      sumx2+=i*i;
   
      x++;
   }

   c=sumx2*pPeriodo-sumx*sumx;
   
   if(c==0.0)
   {
      Print("Erro no calculo da regressão linear!");
      return;
   }

   b=(sumxy*pPeriodo-sumx*sumy)/c;
   a=(sumy-sumx*b)/pPeriodo;

   x = 0;
   while(x<pPeriodo)
   {
      i = (x + pIndiceBarra); 
      
      if(x==0)
         pVlrDir = a+b*i;
      else if(x==(pPeriodo-1))
         pVlrEsq = a+b*i;      
     
      x++;
   }

}


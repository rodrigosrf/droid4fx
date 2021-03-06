//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico           = 1001;
input double Lote                = 0.01;
input int    Periodo             = 21;
input int    Profit              = 100;
input int    StopLoss            = 0;
input int    Proximidade         = 5;
input int    OrdensTotal         = 50;
input int    OrdensDistancia     = 1;
input double LucroFechamento     = 0;
input bool   Martingale          = false;

string versao = "Versão: 3.0";

datetime dtCalculado  = 0;
int      ultOrdem     = -1;
int      ultTicket    = 0;
int      direcaoCanal = -1;

int OnInit()
{
   dtCalculado  = 0;
   ultOrdem     = -1;   
   ultTicket    = 0;
   direcaoCanal = -1;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   dtCalculado  = 0;
   ultOrdem     = -1;   
   ultTicket    = 0;
   direcaoCanal = -1;
}

void OnTick()
{

   int    vTicket     = 0;
   int    i           = 0;
   double vStopProfit = 0;
   double vStopLoss   = 0;   
   double vPonto      = (Point() * 10);
   
   double valorEsq = 0;
   double valorDir = 0;   
   double lucro    = 0;
   double valorEnt = 0;
   double vLote    = 0;
   
   string comentario = "";
   
   if(Volume[0]<3) return;
   
   if(OrdersTotal()>0) lucro = LucroTotal();
   
   if(LucroFechamento>0 && OrdersTotal()>0)
   {
      if(lucro>=LucroFechamento)
      {
         FecharOperacoes(OP_SELLSTOP);
         FecharOperacoes(OP_SELL);      
         FecharOperacoes(OP_BUYSTOP); 
         FecharOperacoes(OP_BUY);    
      }
   }
   
   if(dtCalculado!=Time[0])
   {
   
      CalcRegLinear(Periodo, 1, valorEsq, valorDir);
      
      if(valorEsq>0 && valorDir>0) 
      {
         if(valorEsq<valorDir)
         {
            FecharOperacoes(OP_SELLSTOP);
            FecharOperacoes(OP_SELL);

            direcaoCanal = OP_BUY;

            if(!ExisteOrdemAtiva(OP_SELL) && !ExisteOrdemAtiva(OP_SELLSTOP))
               dtCalculado = Time[0]; 
         }
         else if(valorEsq>valorDir)
         {
            FecharOperacoes(OP_BUYSTOP); 
            FecharOperacoes(OP_BUY); 

            direcaoCanal = OP_SELL;
                                    
            if(!ExisteOrdemAtiva(OP_BUY) && !ExisteOrdemAtiva(OP_BUYSTOP))
               dtCalculado = Time[0];            
         }
      }   
   }
   else if (!ExisteOrdemAtiva(OP_BUY) && !ExisteOrdemAtiva(OP_BUYSTOP) &&
            !ExisteOrdemAtiva(OP_SELL) && !ExisteOrdemAtiva(OP_SELLSTOP))
   {
   
      CalcRegLinear(Periodo, 0, valorEsq, valorDir);

      if(valorEsq>0 && valorDir>0) 
      {
         if(direcaoCanal==OP_BUY && Close[0]<=(valorDir + (Proximidade * vPonto)) && ultOrdem!=OP_BUY)
         {
         
            if(ultOrdem==-1) 
            {
               ultOrdem = OP_BUY;
               return;
            }
         
            if(Profit > 0)   vStopProfit = (Ask + (Profit * vPonto));
            if(StopLoss > 0) vStopLoss   = (Ask - (StopLoss * vPonto));
         
            valorEnt = Ask;
         
            if(!Martingale) 
               vLote = Lote;
            else
               vLote = UltimoLote();
         
            for(i=1; i<=OrdensTotal; i++)
            {
            
               if(i==1)
               {
                  vTicket = OrderSend(
                              _Symbol, 
                              OP_BUY, 
                              vLote, 
                              valorEnt, 
                              3, vStopLoss, vStopProfit, "#1", NumMagico, 0, Blue);
                              
                  if(vTicket>0)
                  {
                     ultOrdem = OP_BUY;
                     ultTicket = vTicket;
                  }
               }         
               else
               {
                  vTicket = OrderSend(
                              _Symbol, 
                              OP_BUYSTOP, 
                              vLote, 
                              valorEnt, 
                              3, 0, vStopProfit, "", NumMagico, 0, Blue);         
               }
               valorEnt = valorEnt + (OrdensDistancia * vPonto);
            }
            
         }
         else if(direcaoCanal==OP_SELL && Close[0]>=(valorDir - (Proximidade * vPonto)) && ultOrdem!=OP_SELL)
         {
   
            if(ultOrdem==-1) 
            {
               ultOrdem = OP_SELL;
               return;
            }
   
            if(Profit > 0)   vStopProfit = (Bid - (Profit * vPonto));
            if(StopLoss > 0) vStopLoss   = (Bid + (StopLoss * vPonto));         
   
            valorEnt = Bid;
                  
            if(!Martingale) 
               vLote = Lote;
            else
               vLote = UltimoLote();
                  
            for(i=1; i<=OrdensTotal; i++)
            {
            
               if(i==1)
               {               
                  vTicket = OrderSend(
                              _Symbol, 
                              OP_SELL, 
                              vLote, 
                              valorEnt, 
                              3, vStopLoss, vStopProfit, "#1", NumMagico, 0, Blue);   
                              
                  if(vTicket>0)
                  {
                     ultOrdem = OP_SELL;
                     ultTicket = vTicket;
                  }                              
               }         
               else
               {
                  vTicket = OrderSend(
                              _Symbol, 
                              OP_SELLSTOP, 
                              vLote, 
                              valorEnt, 
                              3, 0, vStopProfit, "", NumMagico, 0, Blue);         
               }
               valorEnt = valorEnt - (OrdensDistancia * vPonto);
            }                     
                        
         }
      }
   }

   comentario = "Versão: " + versao + "\n" +
           "Valor Esquerda: " + DoubleToString(valorEsq) + "\n" +   
           "Valor Direita: " + DoubleToString(valorDir);
           
   if(valorEsq<valorDir)
      comentario = comentario + "\nAproximidade: " + DoubleToString( valorDir + (Proximidade * vPonto) );
   else if(valorEsq>valorDir)  
      comentario = comentario + "\nAproximidade: " + DoubleToString( valorDir - (Proximidade * vPonto) );
      
   comentario = comentario + "\nLucro: " + DoubleToString(lucro, 5);   
      
   Comment(comentario);
            
}

void FecharOperacoes(int pTipo)
{
   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol)
            if(pTipo==-1 || pTipo==OrderType())
               if(OrderMagicNumber()==NumMagico)
                  if(OrderType()!=OP_BUYSTOP && OrderType()!=OP_SELLSTOP)
                  {
                     if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Yellow))
                        Print("Erro ao fechar ordem. Ticket: " + IntegerToString(OrderTicket()));
                  }
                  else
                  {
                     if(!OrderDelete(OrderTicket()))
                        Print("Erro ao deletar ordem. Ticket: " + IntegerToString(OrderTicket()));                     
                  }      
   }

}   

double UltimoLote()
{

   double lote = Lote;

   if(ultTicket>0)
   {
      if(OrderSelect(ultTicket, SELECT_BY_TICKET, MODE_HISTORY))
      {
         if(OrderProfit()<0) lote = (OrderLots() * 2);
      }
      else if(OrderSelect(ultTicket, SELECT_BY_TICKET, MODE_TRADES))
      {
         if(OrderProfit()<0) lote = (OrderLots() * 2);      
      }
   }
      
   return lote;

}

bool ExisteOrdemAtiva(int pTipo)
{

   bool encontrado = false;

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol)
            if(OrderMagicNumber()==NumMagico && OrderType()==pTipo)
            {
               encontrado = true;
               break;
            }   
   }
   
   return encontrado;

}

double LucroTotal()
{

   double valor = 0;

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol)
            if(OrderMagicNumber()==NumMagico)
               valor += OrderProfit();
   }
   
   return valor;

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


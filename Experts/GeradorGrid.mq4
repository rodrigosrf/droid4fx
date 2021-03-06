//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int  NumMagico            = 1001;
input int  TotalGrid            = 10;
input int  DistanciaInicialGrid = 10;
input int  DistanciaGrid        = 5;
input bool Compra               = true;
input bool Venda                = true;

string versao = "Versão: 3.0";

string ticketsGerados = "";

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{

   int vTicket = 0;
   int x = 0;

   double vLote = 0;
   double valorInicial = 0;

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol()==_Symbol && StringFind(OrderComment(), "#")==-1)
         {
         
            vTicket = OrderTicket();
            vLote   = OrderLots();
         
            if(StringFind(ticketsGerados, ("#" + IntegerToString(vTicket)))==-1)
            {
               if(Compra)
               {
                  for(x=1; x<=TotalGrid; x++)
                  {
                     if(x==1)
                        valorInicial = OrderOpenPrice() + (DistanciaInicialGrid * (Point * 10));  
                     else
                        valorInicial = valorInicial + (DistanciaGrid * (Point * 10));  
                        
                     OrderSend(
                        _Symbol, 
                        OP_BUYSTOP, 
                        vLote, 
                        valorInicial, 
                        3, 0, 0, "#", NumMagico, 0, Blue);         
                  }     
               }
                  
               if(Venda)
               {
                  for(x=1; x<=TotalGrid; x++)
                  {
                     if(x==1)
                        valorInicial = OrderOpenPrice() - (DistanciaInicialGrid * (Point * 10));  
                     else
                        valorInicial = valorInicial - (DistanciaGrid * (Point * 10));  
                        
                     OrderSend(
                        _Symbol, 
                        OP_SELLSTOP, 
                        vLote, 
                        valorInicial, 
                        3, 0, 0, "#", NumMagico, 0, Blue);         
                  }     
               }

               ticketsGerados = ticketsGerados + ("#" + IntegerToString(vTicket));    
            }
         }
      }   
   }      

}

//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico = 3001;
input double Lote      = 0.01;
input int    Periodo   = 3;

string versao = "Versão: 1.0";

datetime dtCalculado = 0;

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

   double vMedia0 = 0, vMedia1 = 0;
   int    vTicket = 0;
   
   if(Volume[0]<=1) return;
 
   if(dtCalculado!=Time[1])
   {
      vMedia1 = iMA(_Symbol, 0, Periodo, 0, MODE_EMA, PRICE_CLOSE, 1);

      if(Close[1]<vMedia)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_BUY, 
                     Lote, 
                     Ask, 
                     3, 0, 0, "", NumMagico, 0, Blue);      
      }
      else if(Close[1]>vMedia)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_SELL, 
                     Lote, 
                     Bid, 
                     3, 0, 0, "", NumMagico, 0, Blue);         
      }
      
      if(ticket>0) dtCalculado = Time[1];
   }

   if(OrdersTotal()>0)
   {
      vMedia0 = iMA(_Symbol, 0, Periodo, 0, MODE_EMA, PRICE_CLOSE, 0);
      
      if(Low[0]<=vMedia0)
      {
         FecharOperacoes(OP_SELL);
      }
      else if(High[0]>=vMedia0)
      {
         FecharOperacoes(OP_BUY);   
      }
   }  
}

void FecharOperacoes(int pTipo)
{
   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol)
            if(pTipo==-1 || pTipo==OrderType())
               if(OrderMagicNumber()==NumMagico)
                  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Yellow))
                     Print("Erro ao fechar ordem. Ticket: " + IntegerToString(OrderTicket()));
   }
}   
//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico           = 1001;
input double Lote                = 0.01;
input int    GRID                = 3;
input int    HoraInicio          = 4;
input int    HoraFim             = 8;

string versao = "Versão: 1.0";

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{

   double vProjecao = (GRID * (Point * 10));
   int    vTipo = -1;
   int    vTicket = 0;
   double vLote = 0;
   double vPrecoAbertura = 0;
   double vDiferenca = 0;
   bool   vHoraValida = false;
   
   double vPreco = 0;
   
   vHoraValida = ((HoraInicio==0 && HoraFim==0) ||
                  (Hour()>=HoraInicio && Hour()<=HoraFim));

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==NumMagico)
         {
            vLote   = OrderLots();
            vTipo   = OrderType();  
            vPrecoAbertura = OrderOpenPrice();          
            vTicket = OrderTicket();
            
            break;
         }   
   }   

   if(vTicket>0)
   {
      if(vTipo==OP_BUY)   
      {
         vDiferenca = (Bid - vPrecoAbertura);
      }
      else if(vTipo==OP_SELL)
      {
         vDiferenca = (vPrecoAbertura - Ask);
      }
   
      if(vDiferenca>=vProjecao)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     vTipo, 
                     Lote, 
                     vPreco, 
                     3, 0, 0, "", NumMagico, 0, Blue);   
      }
      else if(vDiferenca<=-vProjecao)
      {
      
         if(vTipo==OP_BUY)
            vTipo=OP_SELL;   
         else
            vTipo=OP_BUY;               
      
         vLote = (vLote * 2);
      
         FecharOperacoes();
         vTicket = OrderSend(
                     _Symbol, 
                     vTipo, 
                     vLote, 
                     vPreco, 
                     3, 0, 0, "", NumMagico, 0, Blue);         
      }   
   }
   
}

void FecharOperacoes()
{
   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==NumMagico)
            if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Yellow))
               Print("Erro ao fechar ordem. Ticket: " + IntegerToString(OrderTicket()));
   }

}   

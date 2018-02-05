//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico   = 8001;
input int    GridOrdens  = 1;

bool executado = false;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{

   int    i     = 0;
   double valor = 0;
   double ponto = (Point * 10);   
   int    vTicket = 0;
   
   valor = Bid;
   
   for(i=0; i<100; i++)
   {
      valor = (valor - ponto);         
   
      vTicket = OrderSend(
                  _Symbol, 
                  OP_SELLSTOP, 
                  0.01, 
                  valor, 
                  3, 0, 0, "", NumMagico, 0, Blue);         
   
   }
   
   executado = true;

}


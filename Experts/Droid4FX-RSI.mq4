//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    NumMagico = 4001;
input double Lote      = 0.01;
input int    Periodo   = 3;
input int    TotalPips = 10;

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

}   
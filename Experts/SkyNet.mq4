//+------------------------------------------------------------------+
//|                                               Droid4FX-MOD37.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
input int    EST_GRID_NumMagico           = 1001;
input double EST_GRID_Lote                = 0.01;
input int    EST_GRID_GRID                = 3;
input int    EST_GRID_HoraInicio          = 4;
input int    EST_GRID_HoraFim             = 8;

input int    EST_CONTRA_MEDIA_NumMagico   = 1001;
input double EST_CONTRA_MEDIA_Lote        = 0.01;
input int    EST_CONTRA_MEDIA_PERIODO     = 3;
input int    EST_CONTRA_MEDIA_HoraInicio  = 4;
input int    EST_CONTRA_MEDIA_HoraFim     = 8;

string versao = "Versão: 1.0";

#include "EST_GRID.mq4"
#include "EST_CONTRA_MEDIA.mq4"

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{
   EST_GRID_START(EST_GRID_Lote, EST_GRID_GRID, EST_GRID_NumMagico, EST_GRID_HoraInicio, EST_GRID_HoraFim);
   EST_CONTRA_MEDIA(EST_GRID_Lote, EST_CONTRA_MEDIA_PERIODO, EST_GRID_NumMagico, EST_GRID_HoraInicio, EST_GRID_HoraFim);   
}

void FecharOperacoes(int pTipo, int pNumMagico)
{
   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==pNumMagico)
            if(pTipo==-1 || OrderType()==pTipo)
               if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Yellow))
                  Print("Erro ao fechar ordem. Ticket: " + IntegerToString(OrderTicket()));
   }

}   

#include <Object.mqh>
#include <Trade\Trade.mqh>

#define MA_MAGIC 1234501

input double DistanciaGrid = 5;
input int    PeriodoMedia  = 21;
input double Lote          = 0.01;
input bool   Martingale    = true;

class CEstGridTrend : public CObject
{
private:
   int               ma_handle;
   CTrade            trade;
public:
   ENUM_INIT_RETCODE Iniciar();
   void              Executar();
};

ENUM_INIT_RETCODE CEstGridTrend::Iniciar()
{
   ma_handle=iMA(_Symbol,_Period,PeriodoMedia,0,MODE_EMA,PRICE_CLOSE);
   if(ma_handle==INVALID_HANDLE)
   {
      printf("Error creating MA indicator");
      return(INIT_FAILED);
   }   
   
   trade.SetExpertMagicNumber(MA_MAGIC);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(3);

   return(INIT_SUCCEEDED);      
}

void CEstGridTrend::Executar()
{
   MqlRates rt[2];
   double   ma[1];
   double   spread     = 0;
   int      total      = 0;
   double   vlAbertura = 0;
   double   vlAtual    = 0;   
   long     tipo       = -1;
   long     ticket     = 0;   
   long     magic      = 0;
   string   simbolo    = "";
   
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
   {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
   }

   if(CopyBuffer(ma_handle,0,1,1,ma)!=1)
   {
      Print("CopyBuffer from iMA failed, no data");
      return;
   }
   
   total = PositionsTotal();
   
   for(int pos=total-1; pos>=0; pos--)
   {
     
      PositionGetString(POSITION_SYMBOL, simbolo); 
      PositionGetDouble(POSITION_PRICE_OPEN, vlAbertura);
      PositionGetDouble(POSITION_PRICE_CURRENT, vlAtual);
      PositionGetInteger(POSITION_TYPE, tipo);
      PositionGetInteger(POSITION_TICKET, ticket);      
      PositionGetInteger(POSITION_MAGIC, magic); 


      if(magic!=MA_MAGIC) continue;
      if(simbolo!=_Symbol) continue;

      
      if(tipo==POSITION_TYPE_BUY)
      {
         if(rt[1].close<ma[0])
            trade.PositionClose(ticket);
         else   
         {
            spread = ((vlAtual-vlAbertura) * _Point);
            
            if(spread>=DistanciaGrid)
            {
               if(!trade.PositionModify(ticket, vlAbertura, 0))
               {
                  PrintResultTrade(trade);
               }
               else
               {
                  if(!trade.Buy(Lote))
                  {
                     PrintResultTrade(trade);
                  }
               }   
            }
         }   
      }   
      else if(tipo==POSITION_TYPE_SELL)
      {
         if(rt[1].close>ma[0])
            trade.PositionClose(ticket);
         else   
         {
            spread = ((vlAbertura-vlAtual) * _Point);
            
            if(spread>=DistanciaGrid)
            {
               if(!trade.PositionModify(ticket, vlAbertura, 0))
               {
                  PrintResultTrade(trade);
               }
               else
               {
                  if(!trade.Sell(Lote))
                  {
                     PrintResultTrade(trade);
                  }
               }               
            }   
         }   
      }   
      
   }

   if (PositionsTotal()==0)
   {
      if(rt[1].close>ma[0])
      {
         if(!trade.Buy(Lote))
         {
            PrintResultTrade(trade);
         }
      }
      else if(rt[1].close<ma[0])
      {
         if(!trade.Sell(Lote))
         {
            PrintResultTrade(trade);
         }
      }
   }

}

void PrintResultTrade(CTrade &trade)
{
   Print("File: ",__FILE__,", symbol: ", _Symbol);
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(), Digits()));
   Print("Broker comment: "+trade.ResultComment());
}  

  
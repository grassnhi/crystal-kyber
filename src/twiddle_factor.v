`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2024 10:51:24 AM
// Design Name: 
// Module Name: twiddle_factor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module twiddle_factor(
    input clk,
    input [6:0] addr,
    output [23:0] dout
    );
    
(* rom_style = "block" *) reg [11:0] data [0:127];

assign dout = {data[addr + 1], data[addr]};

always (@posedge clk) begin
    data[0] <= 12'h001;
    data[1] <= 12'h6c1;
    data[2] <= 12'ha14;
    data[3] <= 12'hcd9;
    data[4] <= 12'ha52;
    data[5] <= 12'h276;
    data[6] <= 12'h769;
    data[7] <= 12'h350;
    data[8] <= 12'h426;
    data[9] <= 12'h77f;
    data[10] <= 12'h0c1;
    data[11] <= 12'h31d;
    data[12] <= 12'hae2;
    data[13] <= 12'hcbc;
    data[14] <= 12'h239;
    data[15] <= 12'h6d2;
    data[16] <= 12'h128;
    data[17] <= 12'h98f;
    data[18] <= 12'h53b;
    data[19] <= 12'h5c4;
    data[20] <= 12'hbe6;
    data[21] <= 12'h038;
    data[22] <= 12'h8c0;
    data[23] <= 12'h535;
    data[24] <= 12'h592;
    data[25] <= 12'h82e;
    data[26] <= 12'h217;
    data[27] <= 12'hb42;
    data[28] <= 12'h959;
    data[29] <= 12'hb3f;
    data[30] <= 12'h7b6;
    data[31] <= 12'h335;
    data[32] <= 12'h121;
    data[33] <= 12'h14b;
    data[34] <= 12'hcb5;
    data[35] <= 12'h6dc;
    data[36] <= 12'h4ad;
    data[37] <= 12'h900;
    data[38] <= 12'h8e5;
    data[39] <= 12'h807;
    data[40] <= 12'h28a;
    data[41] <= 12'h7b9;
    data[42] <= 12'h9d1;
    data[43] <= 12'h278;
    data[44] <= 12'hb31;
    data[45] <= 12'h021;
    data[46] <= 12'h528;
    data[47] <= 12'h77b;
    data[48] <= 12'h90f;
    data[49] <= 12'h59b;
    data[50] <= 12'h327;
    data[51] <= 12'h1c4;
    data[52] <= 12'h59e;    
    data[53] <= 12'hb34;
    data[54] <= 12'h5fe;
    data[55] <= 12'h962;
    data[56] <= 12'ha57;
    data[57] <= 12'ha39;
    data[58] <= 12'h5c9;
    data[59] <= 12'h288;
    data[60] <= 12'h9aa;
    data[61] <= 12'hc26;
    data[62] <= 12'h4cb;
    data[63] <= 12'h38e;
    data[64] <= 12'h011;
    data[65] <= 12'hac9;
    data[66] <= 12'h247;
    data[67] <= 12'ha59;
    data[68] <= 12'h665;
    data[69] <= 12'h2d3;
    data[70] <= 12'h8f0;
    data[71] <= 12'h44c;
    data[72] <= 12'h581;
    data[73] <= 12'ha66;
    data[74] <= 12'hcd1;
    data[75] <= 12'h0e9;
    data[76] <= 12'h2f4;
    data[77] <= 12'h86c;
    data[78] <= 12'hbc7;
    data[79] <= 12'hbea;
    data[80] <= 12'h6a7;
    data[81] <= 12'h673;
    data[82] <= 12'hae5;
    data[83] <= 12'h6fd;
    data[84] <= 12'h737;
    data[85] <= 12'h3b8;
    data[86] <= 12'h5b5;
    data[87] <= 12'ha7f;
    data[88] <= 12'h3ab;
    data[89] <= 12'h904;
    data[90] <= 12'h985;
    data[91] <= 12'h954;
    data[92] <= 12'h2dd;
    data[93] <= 12'h921;
    data[94] <= 12'h10c;
    data[95] <= 12'h281;
    data[96] <= 12'h630;
    data[97] <= 12'h8fa;
    data[98] <= 12'h7f5;
    data[99] <= 12'hc94;
    data[100] <= 12'h177;
    data[101] <= 12'h9f5;
    data[102] <= 12'h82a;
    data[103] <= 12'h66d;
    data[104] <= 12'h427;
    data[105] <= 12'h13f;
    data[106] <= 12'had5;
    data[107] <= 12'h2f5;
    data[108] <= 12'h833;
    data[109] <= 12'h231;
    data[110] <= 12'h9a2;
    data[111] <= 12'ha22;
    data[112] <= 12'haf4;
    data[113] <= 12'h444;
    data[114] <= 12'h193;
    data[115] <= 12'h402;
    data[116] <= 12'h477;
    data[117] <= 12'h866;
    data[118] <= 12'had7;
    data[119] <= 12'h376;
    data[120] <= 12'h6ba;
    data[121] <= 12'h4bc;
    data[122] <= 12'h752;
    data[123] <= 12'h405;
    data[124] <= 12'h83e;
    data[125] <= 12'hb77;
    data[126] <= 12'h375;
    data[127] <= 12'h86a;
end

endmodule

// Index  x (Dec)    x^-2 mod 3329   x^-1.5 mod 3329    x^-1 mod 3329   x^1 mod 3329 x^1.5 mod 3329     x^2 mod 3329
// ----------------------------------------------------------------------------------------------------
// 0      1          1               1                  1               1            1                  1           
// 1      1729       3328            749                1600            1729         40                 3328        
// 2      2580       1600            2699               40              2580         1432               1729        
// 3      3289       1729            2481               749             3289         687                1600        
// 4      2642       40              797                2481            2642         2786               2580        
// 5      630        3289            1062               1432            630          1746               749         
// 6      1905       369             504                526             1905         1539               415         
// 7      848        2580            3260               687             848          193                40          
// 8      1062       2481            1333               1583            1062         1426               2642        
// 9      1919       848             283                2760            1919         447                687         
// 10     193        1432            2447               69              193          1974               630         
// 11     797        1897            1476               543             797          2393               2699        
// 12     2786       2699            450                2532            2786         1990               1897        
// 13     3244       1961            Undefined          3094            3244         Undefined          567         
// 14     569        687             535                1410            569          56                 848         
// 15     1746       2642            1235               2267            1746         1089               2481        
// 16     296        1583            1414               2508            296          1010               1062        
// 17     2447       1746            2865               1355            2447         452                2267        
// 18     1339       2760            1977               450             1339         1534               1919        
// 19     1476       569             2697               936             1476         1891               1410        
// 20     3046       69              1756               447             3046         2474               193         
// 21     56         3260            3040               2794            56           2419               3136        
// 22     2240       543             1052               1235            2240         712                797         
// 23     1333       2786            1025               1903            1333         1848               2532        
// 24     1426       2532            2681               1996            1426         2132               2786        
// 25     2094       797             2647               1089            2094         2055               543         
// 26     535        3136            2102               3273            535          2998               3260        
// 27     2882       193             219                283             2882         76                 69          
// 28     2393       1410            2868               1853            2393         2513               569         
// 29     2879       1919            2402               1990            2879         650                2760        
// 30     1974       2267            807                882             1974         33                 1746        
// 31     821        1062            1435               3033            821          1320               1583        
// 32     289        2508            641                2419            289          1584               296         
// 33     331        821             2596               2102            331          109                3033        
// 34     3253       1355            2308               219             3253         2090               2447        
// 35     1756       1974            2388               855             1756         375                882         
// 36     1197       450             1540               2681            1197         1230               1339        
// 37     2304       2879            1703               1848            2304         2594               1990        
// 38     2277       936             1868               712             2277         3010               1476        
// 39     2055       2393            2377               682             2055         556                1853        
// 40     650        447             2229               927             650          1607               3046        
// 41     1977       2882            1637               1795            1977         1029               283         
// 42     2513       2794            2761               461             2513         885                56          
// 43     632        535             2649               1891            632          2110               3273        
// 44     2865       1235            1173               2877            2865         2926               2240        
// 45     33         2094            3050               2522            33           2804               1089        
// 46     1320       1903            48                 1894            1320         1179               1333        
// 47     1915       1426            667                1010            1915         554                1996        
// 48     2319       1996            2443               1414            2319         1920               1426        
// 49     1435       1333            2186               2009            1435         3096               1903        
// 50     807        1089            2237               3296            807          314                2094        
// 51     452        2240            2303               464             452          2573               1235        
// 52     1438       3273            2935               2697            1438         583                535         
// 53     2868       56              2154               816             2868         17                 2794        
// 54     1534       283             1874               1352            1534         723                2882        
// 55     2402       3046            1212               2679            2402         2288               447         
// 56     2647       1853            757                1274            2647         1847               2393        
// 57     2617       1476            2266               1052            2617         642                936         
// 58     1481       1990            863                1025            1481         1678               2879        
// 59     648        1339            561                2132            648          2789               450         
// 60     2474       882             780                1573            2474         892                1974        
// 61     3110       2447            1684               76              3110         2390               1355        
// 62     1227       3033            2037               2998            1227         2337               821         
// 63     910        296             2298               3040            910          268                2508        
// 64     17         2419            Undefined          1175            17           Undefined          289         
// 65     2761       910             Undefined          2444            2761         Undefined          3040        
// 66     583        2102            Undefined          394             583          Undefined          331         
// 67     2649       1227            Undefined          1219            2649         Undefined          2998        
// 68     1637       219             Undefined          2300            1637         Undefined          3253        
// 69     723        3110            Undefined          1455            723          Undefined          76          
// 70     2288       855             Undefined          2117            2288         Undefined          1756        
// 71     1100       2474            Undefined          1607            1100         Undefined          1573        
// 72     1409       2681            Undefined          2443            1409         Undefined          1197        
// 73     2662       648             Undefined          554             2662         Undefined          2132        
// 74     3281       1848            Undefined          1179            3281         Undefined          2304        
// 75     233        1481            Undefined          2186            233          Undefined          1025        
// 76     756        712             Undefined          2303            756          Undefined          2277        
// 77     2156       2617            Undefined          2926            2156         Undefined          1052        
// 78     3015       682             Undefined          2237            3015         Undefined          2055        
// 79     3050       2647            Undefined          525             3050         Undefined          1274        
// 80     1703       927             Undefined          735             1703         Undefined          650         
// 81     1651       2402            Undefined          863             1651         Undefined          2679        
// 82     2789       1795            Undefined          2768            2789         Undefined          1977        
// 83     1789       1534            Undefined          1230            1789         Undefined          1352        
// 84     1847       461             Undefined          2572            1847         Undefined          2513        
// 85     952        2868            Undefined          556             952          Undefined          816         
// 86     1461       1891            Undefined          3010            1461         Undefined          632         
// 87     2687       1438            Undefined          2266            2687         Undefined          2697        
// 88     939        2877            Undefined          1684            939          Undefined          2865        
// 89     2308       452             Undefined          1239            2308         Undefined          464         
// 90     2437       2522            Undefined          780             2437         Undefined          33          
// 91     2388       807             Undefined          2954            2388         Undefined          3296        
// 92     733        1894            Undefined          109             733          Undefined          1320        
// 93     2337       1435            Undefined          1292            2337         Undefined          2009        
// 94     268        1010            Undefined          1031            268          Undefined          1915        
// 95     641        2319            Undefined          1745            641          Undefined          1414        
// 96     1584       1414            Undefined          2688            1584         Undefined          2319        
// 97     2298       1915            Undefined          3061            2298         Undefined          1010        
// 98     2037       2009            Undefined          992             2037         Undefined          1435        
// 99     3220       1320            Undefined          2596            3220         Undefined          1894        
// 100    375        3296            Undefined          941             375          Undefined          807         
// 101    2549       33              Undefined          892             2549         Undefined          2522        
// 102    2090       464             Undefined          1021            2090         Undefined          452         
// 103    1645       2865            Undefined          2390            1645         Undefined          2877        
// 104    1063       2697            Undefined          642             1063         Undefined          1438        
// 105    319        632             Undefined          1868            319          Undefined          1891        
// 106    2773       816             Undefined          2377            2773         Undefined          2868        
// 107    757        2513            Undefined          1482            757          Undefined          461         
// 108    2099       1352            Undefined          1540            2099         Undefined          1534        
// 109    561        1977            Undefined          540             561          Undefined          1795        
// 110    2466       2679            Undefined          1678            2466         Undefined          2402        
// 111    2594       650             Undefined          1626            2594         Undefined          927         
// 112    2804       1274            Undefined          279             2804         Undefined          2647        
// 113    1092       2055            Undefined          314             1092         Undefined          682         
// 114    403        1052            Undefined          1173            403          Undefined          2617        
// 115    1026       2277            Undefined          2573            1026         Undefined          712         
// 116    1143       1025            Undefined          3096            1143         Undefined          1481        
// 117    2150       2304            Undefined          48              2150         Undefined          1848        
// 118    2775       2132            Undefined          667             2775         Undefined          648         
// 119    886        1197            Undefined          1920            886          Undefined          2681        
// 120    1722       1573            Undefined          2229            1722         Undefined          2474        
// 121    1212       1756            Undefined          1041            1212         Undefined          855         
// 122    1874       76              Undefined          2606            1874         Undefined          3110        
// 123    1029       3253            Undefined          1692            1029         Undefined          219         
// 124    2110       2998            Undefined          680             2110         Undefined          1227        
// 125    2935       331             Undefined          2746            2935         Undefined          2102        
// 126    885        3040            Undefined          568             885          Undefined          910         
// 127    2154       289             Undefined          3312            2154         Undefined          2419        
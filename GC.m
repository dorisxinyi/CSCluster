classdef GC
    %GLOBALCONST Summary of this class goes here

    properties
    end
    
    methods(Static=true)

        function val = ALG_CLS_HYBCS % clustering with hybrid CS centralized algorithm
            val = 1;
        end
        
        function val = ALG_CLS_HYBCS_DISTR % clustering with hybrid CS distributed algorithm
            val = 2;
        end
        
        function val = ALG_OPTTREE_CS % optial tree with hybrid CS
            val = 3;
        end
        
        function val = ALG_SPT_CS % SPT with hybrid CS
            val = 4;
        end
        
        function val = ALG_SPT % SPT without CS
            val = 5;
        end
        
        function val = ALG_CLS % clustering without CS
            val = 6;
        end    
        
        function val = ALG_ANALY % analytical value
            val = 7;
        end
        
        function val = ALGTYPE
            val = 7;
        end
        
        function val = LOAD_CLS_HYBCS
            val = 1;
        end
        
        function val = LOAD_CLS_HYBCS_DISTR
            val = 2;
        end
        
        function val = LOAD_OPTTREE_CS
            val = 3;
        end
        
        function val = LOADTYPE
            val = 3;
        end
        
        function val = ITER_CLS_HYBCS
            val = 1;
        end
        
        function val = ITER_CLS_HYBCS_DISTR
            val = 2;
        end
        
        function val = ITER_OPTTREE_CS
            val = 3;
        end
        
        function val = ITERTYPE
            val = 3;
        end       
                
        function val = FIGTYPE_HIST
            val = 21;
        end
        
        function val = FIGTYPE_CDF
            val = 22;
        end
    end
    
end


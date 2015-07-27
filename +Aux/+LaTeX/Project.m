classdef Project < Aux.KeyValueUtils.KeyValueMixin
    
    
    properties (SetAccess = protected, GetAccess = public)
        docList;
        projectPath;
    end
    
    properties (Access = protected)
        mainDocNum = 1;
        args = {'-interaction=nonstopmode'};
        numCmpl = 2;
        debugOn;
        echoArg;
    end
    
    properties (Dependent, SetAccess = immutable, GetAccess = public)
        figPathCmplDir;
        figPathCurrDir;
        docNames;
        docNamesListed;
    end
    
    properties (Constant, Access = protected)
        figFolderName = 'figures';
    end
    
    
    methods
        function obj = Project(rootPath, projectName)
            rootPath = Aux.FileHandling.FormatFolderPath(rootPath);
            obj.projectPath = [rootPath, projectName, '/'];
            
            if ~exist(obj.projectPath, 'dir')
                mkdir(obj.projectPath);
            end
            
            if ~exist(obj.figPathCurrDir, 'dir')
                mkdir(obj.figPathCurrDir);
            end
            
            obj.Set('echo', true);
            obj.Set('debug', true);
        end
        
        function delete(obj)
            obj.CloseAll;
        end
        
        function CloseAll(obj)
            % Close all documents
            arrayfun(@(d) d.Close, obj.docList);
        end
        
        function newDoc = AddDocument(obj, newDocName)
            nameMatches = strcmp(newDocName, obj.docNames);
            
            if any(nameMatches)
                error('Document ''%s'' already exists!', newDocName);
            end
            
            newDoc = Aux.LaTeX.Document([obj.projectPath, newDocName]);
            obj.docList = [obj.docList, newDoc];
        end
        
        function CleanUp(~)
        end
        
        function Compile(obj)
            % Close all documents
            obj.CloseAll;
            
            % Compile the main document
            mainDoc = obj.docList(obj.mainDocNum);
            mainDocName = [mainDoc.filename, '.tex'];
            
            cmplCom{1} = 'pdflatex';
            cmplCom{2} = mainDocName;
            cmplCom{3} = ['-output-directory=', obj.projectPath];
            cmplCom = strjoin([cmplCom, obj.args]);
            
            if obj.debugOn
                fprintf('Running pdfLaTeX...\n\t');
            end
            for i = 1 : 1 : obj.numCmpl
                if obj.debugOn
                    fprintf('%i... ', i);
                end
                % Start compilation
                % Use '[~, ~]' to suppress output to MATLAB Command Window
                [~, ~] = dos(cmplCom, obj.echoArg{:});
            end
            if obj.debugOn
                fprintf('done!\n');
            end
        end
        
        function tDoc = AddFromTemplate(obj, templatePath, docName)
            tDoc = obj.AddDocument(docName);
            tDoc.Close;
            copyfile(templatePath, tDoc.fullPath);
            tDoc.Reopen;
        end
        
        function latexStr = PrintTrim(obj, h, figureName, varargin)
            filename = [obj.figPathCurrDir, figureName];
            latexStr = [obj.figPathCmplDir, figureName];
            Aux.FigureOperations.PrintTrim(h, filename, varargin{:});
        end
    end
    
    methods
        function val = get.docNames(obj)
            if ~isempty(obj.docList)
                val = {obj.docList.filename};
            else
                val = [];
            end
        end
        
        function val = get.docNamesListed(obj)
            if ~isempty(obj.docList)
            str1 = {sprintf('Available documents:\n')};
            prtFun = @(x) sprintf('\t''%s''\n', x);
            str2 = cellfun(prtFun, obj.docNames, 'UniformOutput', false);
            val = strjoin([str1, str2], '');
            else
                val = sprintf('No documents available.\n');
            end
        end
        
        function val = get.figPathCmplDir(obj)
            val = ['./', obj.figFolderName, '/'];
        end
        
        function val = get.figPathCurrDir(obj)
            val = [obj.projectPath, obj.figFolderName, '/'];
        end
    end
    
    methods (Hidden)
        function Set.num_pdflatex_runs(obj, val)
            obj.numCmpl = val;
        end
        
        function Set.pdflatex_args(obj, val)
            obj.args = val;
        end
        
        function Set.debug(obj, val)
            obj.debugOn = logical(val);
        end
        
        function Set.echo(obj, val)
            if val
                obj.echoArg = {'-echo'};
            else
                obj.echoArg = {};
            end
        end
        
        function Set.main_document(obj, val)
            nameMatches = strcmp(val, obj.docNames);
            if ~any(nameMatches)
                errStr{1} = sprintf('Document ''%s'' not found!', val);
                errStr{2} = obj.docNamesListed;
                error(strjoin(errStr));
            else
                obj.mainDocNum = find(nameMatches, 1);
                if obj.debugOn
                    fprintf('Document ''%s'' set as main!\n', val);
                end
            end
        end
    end
end
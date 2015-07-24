classdef Project < Aux.KeyValueUtils.KeyValueMixin
    properties (SetAccess = protected, GetAccess = public)
        docList;
        projectPath;
        figPathCompDir;
        figPathCurrDir;
    end
    
    properties (Access = protected)
        args = {' -interaction=nonstopmode'};
        numComp = 2;
        debugOn;
        echoArg;
    end
    
    properties (Constant, Access = protected)
        figFolderName = 'figures';
    end
    
    methods
        function obj = Project(rootPath, projectName)
            rootPath = Aux.FileHandling.FormatFolderPath(rootPath);
            
            obj.Set('echo', true);
            obj.Set('debug', true);
            
            obj.projectPath = [rootPath, projectName, '/'];
            obj.figPathCurrDir = [obj.projectPath, obj.figFolderName, '/'];
            obj.figPathCompDir = ['./', obj.figFolderName, '/'];
            
            if ~exist(obj.projectPath, 'dir')
                mkdir(obj.projectPath);
            end
            
            if ~exist(obj.figPathCurrDir, 'dir')
                mkdir(obj.figPathCurrDir);
            end
        end
        
        function delete(obj)
            obj.CloseAll;
        end
        
        function CloseAll(obj)
            % Close all documents
            arrayfun(@(d) d.Close, obj.docList);
        end
        
        function newDoc = AddDocument(obj, docName)
            newDoc = Aux.LaTeX.Document([obj.projectPath, docName]);
            obj.docList = [obj.docList, newDoc];
        end
        
        function CleanUp(~)
        end
        
        function Compile(obj)
            % Close all documents
            obj.CloseAll;
            
            % Compile the main document
            mainDocName = [obj.docList(1).filename, '.tex'];
            
            compileCom{1} = 'pdflatex';
            compileCom{2} = mainDocName;
            compileCom{3} = ['-output-directory=', obj.projectPath];
            compileCom = strjoin([compileCom, obj.args]);
            
            if obj.debugOn
                fprintf('Running pdfLaTeX...\n\t');
            end
            for i = 1 : 1 : obj.numComp
                if obj.debugOn
                    fprintf('%i... ', i);
                end
                % Start compilation
                % Use '[~, ~]' to suppress output to MATLAB Command Window
                [~, ~] = dos(compileCom, obj.echoArg{:});
            end
            if obj.debugOn
                fprintf('done!\n');
            end
        end
        
        function tDoc = AddFromTemplate(obj, templatePath)
            [~, fName, ~] = fileparts(templatePath);
            
            tDoc = obj.AddDocument(fName);
            
            tDoc.Close;
            copyfile(templatePath, tDoc.fullPath);
            tDoc.Reopen;
        end
    end
    
    methods (Hidden)
        function Set.num_pdflatex_runs(obj, val)
            obj.numComp = val;
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
    end
end
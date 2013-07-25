%% This file were automatically generated by SWIG's MatLab module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                         %%
%%                INTEL CORPORATION PROPRIETARY INFORMATION                %%
%%   This software is supplied under the terms of a license agreement or   %%
%%  nondisclosure agreement with Intel Corporation and may not be copied   %%
%%   or disclosed except in accordance with the terms of that agreement.   %%
%%       Copyright (c) 2003 Intel Corporation. All Rights Reserved.        %%
%%                                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% [OUTPUTOut1, OUTPUTOut2, OUTPUTOut3] = GetObsNodesWithValues(varargin)
%%
%% C++ prototype: void GetObsNodesWithValues(pnl::CEvidence const *self,pnl::intVector *OUTPUT,pnl::valueVecVector *OUTPUT,pnl::pConstNodeTypeVector *OUTPUT)
%%

function [OUTPUTOut1, OUTPUTOut2, OUTPUTOut3] = GetObsNodesWithValues(varargin)

[OUTPUTOut1, OUTPUTOut2, OUTPUTOut3] = feval('pnl_full', 'CEvidence_GetObsNodesWithValues_wrap', varargin{:});
for k = 1:length(OUTPUTOut3)
    OUTPUTOut3{k} = CNodeType('%%@#DefaultCtor', OUTPUTOut3{k});
end

return

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
%% [result] = ConvertFromMNet(varargin)
%%
%% C++ prototype: pnl::CFactorGraph *pnl::CFactorGraph::ConvertFromMNet(pnl::CMNet const *pMNet)
%%

function [result] = ConvertFromMNet(varargin)

[result] = feval('pnl_full', 'CFactorGraph_ConvertFromMNet_wrap', varargin{:});
result = CFactorGraph('%%@#DefaultCtor', result);

return

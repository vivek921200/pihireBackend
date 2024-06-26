USE [piHIRE1.0_QA]
GO

Alter PROCEDURE [dbo].[Sp_Job_Candidate_List_FilterData]
	@JobId int,
	@UserType int,
	@UserId int
AS
BEGIN

   Select 
		Distinct
		--RecruiterID, 
		CandProfStatus,
		--SelfRating,
		--Gender,
		--SourceID,
		CANDIDATE_PROFILE.CountryID,
		CANDIDATE_PROFILE.Nationality
		--NoticePeriod,
		--OpCurrency,
		--OpTakeHomePerMonth,
		--datediff(year, DOB, getdate()) age,
		--MaritalStatus

    from 
		PH_JOB_CANDIDATES as JOB_CANDIDATES WITH(NOLOCK)
		join PH_CANDIDATE_PROFILES as CANDIDATE_PROFILE WITH(NOLOCK) on JOB_CANDIDATES.CandProfId  = CANDIDATE_PROFILE.Id
		--join PH_CAND_STATUS_S as CAND_STATUS_S  WITH(NOLOCK) on JOB_CANDIDATES.CandProfStatus  = CAND_STATUS_S.Id
		    
	where (1 = 1) and (@UserType != 4 or RecruiterID = @UserId) and (@JobId is null or JOID = @JobId);

END
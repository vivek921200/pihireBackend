USE [piHIRE1.0_QA]
GO

ALTER PROCEDURE [dbo].[Sp_CandDtls_Per_Workflow_Rules]
	@JobId int,
	@CandId int
AS
begin

	Select 
		Cand.ContactNo,Cand.EmailId,Cand.CandName,
		CandStatu.Title as CandStatus,JobCand.CandProfStatus,
		JobCand.OpgrossPayPerMonth as OfferGrossPackagePerMonth,
		JobCand.Opcurrency as OfferPackageCurrency,
		JobCand.OptakeHomePerMonth as OfferNetSalMonth,
		JobCand.RecruiterId,
		CUser.Id as UserId,
		CUser.UserName as ToEmail,
		CandIntws.InterviewDate,
		CandIntws.Location as InterviewLoc,
		CandIntws.InterviewStartTime,
		CandIntws.InterviewEndTime,
		CandIntws.InterviewTimeZone,
		CandIntws.ModeOfInterview,
		CandOffer.JoiningDate
	from 
		dbo.Ph_Candidate_Profiles as Cand WITH(NOLOCK) 
		JOIN dbo.Ph_Job_Candidates as JobCand WITH(NOLOCK) on Cand.Id =JobCand.CandProfId 
		JOIN dbo.Pi_Hire_Users as CUser WITH(NOLOCK) on CUser.UserName =Cand.EmailId 
		LEFT OUTER JOIN dbo.PH_CAND_STATUS_S as CandStatu WITH(NOLOCK) on JobCand.CandProfStatus =CandStatu.ID 
		OUTER APPLY
				(
				SELECT  TOP 1 InterviewDate,Location,InterviewStartTime,InterviewEndTime,ModeOfInterview, InterviewTimeZone
				FROM    dbo.PH_JOB_CANDIDATE_INTERVIEWS as CandIntw
				WHERE   JobCand.JOID = CandIntw.JOID and JobCand.CandProfID = CandIntw.CandProfID order by id desc
				) CandIntws
		OUTER APPLY
				(
				SELECT  TOP 1  JoiningDate  FROM [dbo].[PH_JOB_OFFER_LETTERS] as JobOffer
				WHERE   JobCand.JOID = JobOffer.JOID and JobCand.CandProfID = JobOffer.CandProfID order by id desc
				) CandOffer
	where 
		JobCand.JOID = @JobId and JobCand.CandProfId = @CandId
end


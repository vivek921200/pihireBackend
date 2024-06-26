USE [piHIRE1.0_QA]
GO
CREATE OR ALTER PROCEDURE [dbo].[Sp_Dashboard_CandidateInterview]
	@fmDt datetime,
	@toDt datetime,
	@puIds nvarchar(max), 
	@buIds nvarchar(max), 
	@tabId int,
	--pagination
	@fetchCount int,--0 if no pagination
	@offsetCount int,
	--Authorization
	@userType int,
	@userId int
AS
begin
if(@fetchCount != 0)
	select 
		* 
	from 
		vwDashboardCandidateInterview with (nolock)
	where 
		( 
			(@userType = 1) or --SuperAdmin
			(@userType = 2 and jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) inner join [dbo].[vwUserPuBu] vw on /*jbDtl.BUID=vw.[BusinessUnit] and*/ jbDtl.PUID=vw.[ProcessUnit] and vw.UserId=@userId)) or --Admin
			(@userType = 3 and @userId = bdmId) or --BDM
			(@userType = 4 and @userId = recruiterID) or --Recruiter
			(@userType = 5 and @userId = CandProfID) --Candidate
			--Hire manager PH_JOB_OPENINGS_ADDL_DETAILS
		)
		and (@fmDt is null or @toDt is null or InterviewDate between @fmDt and @toDt)
		and (LEN(coalesce(@puIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where PUID in (select cast(value as int) from string_split(@puIds,',')))))
		and (LEN(coalesce(@buIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where BUID in (select cast(value as int) from string_split(@buIds,',')))))
		and (@tabId is null or tabNo=@tabId)
	order by InterviewDate desc offset @offsetCount rows fetch next @fetchCount rows only;

else
	select 
		* 
	from 
		vwDashboardCandidateInterview with (nolock)
	where 
		( 
			(@userType = 1) or --SuperAdmin
			(@userType = 2 and jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) inner join [dbo].[vwUserPuBu] vw on /*jbDtl.BUID=vw.[BusinessUnit] and*/ jbDtl.PUID=vw.[ProcessUnit] and vw.UserId=@userId)) or --Admin
			(@userType = 3 and @userId = bdmId) or --BDM
			(@userType = 4 and @userId = recruiterID) or --Recruiter
			(@userType = 5 and @userId = CandProfID) --Candidate
			--Hire manager PH_JOB_OPENINGS_ADDL_DETAILS
		)
		and (@fmDt is null or @toDt is null or InterviewDate between @fmDt and @toDt)
		and (LEN(coalesce(@puIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where PUID in (select cast(value as int) from string_split(@puIds,',')))))
		and (LEN(coalesce(@buIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where BUID in (select cast(value as int) from string_split(@buIds,',')))))
		and (@tabId is null or tabNo=@tabId)
	order by InterviewDate desc
end
Go

CREATE OR ALTER PROCEDURE [dbo].[Sp_Dashboard_CandidateInterviewCount]
	@fmDt datetime,
	@toDt datetime,
	@puIds nvarchar(max), 
	@buIds nvarchar(max), 
	@tabId int,
	--Authorization
	@userType int,
	@userId int
AS
begin
	select 
		count(1) TotCnt
	from 
		vwDashboardCandidateInterview with (nolock)
	where 
		( 
			(@userType = 1) or --SuperAdmin
			(@userType = 2 and jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) inner join [dbo].[vwUserPuBu] vw on /*jbDtl.BUID=vw.[BusinessUnit] and*/ jbDtl.PUID=vw.[ProcessUnit] and vw.UserId=@userId)) or --Admin
			(@userType = 3 and @userId = bdmId) or --BDM
			(@userType = 4 and @userId = recruiterID) or --Recruiter
			(@userType = 5 and @userId = CandProfID) --Candidate
			--Hire manager PH_JOB_OPENINGS_ADDL_DETAILS
		)
		and (@fmDt is null or @toDt is null or InterviewDate between @fmDt and @toDt)
		and (LEN(coalesce(@puIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where PUID in (select cast(value as int) from string_split(@puIds,',')))))
		and (LEN(coalesce(@buIds,''))=0 or (jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) where BUID in (select cast(value as int) from string_split(@buIds,',')))))
		and (@tabId is null or tabNo=@tabId)
end
Go





CREATE OR ALTER view vwDashboardCandidateInterview
with schemabinding as

	select intrvw.ID,
		intrvw.JOID as JobId,intrvw.CandProfID,
		intrvw.InterviewStatus,intrvw.ModeOfInterview,intrvw.InterviewStartTime,intrvw.InterviewEndTime, 
		job.ClientID, job.ClientName, job.JobTitle, job.ReopenedDate,
		cand.CandName, cand.EmailID, cand.ContactNo,
		max(case when usr.ID = coalesce(job.BroughtBy,job.createdby) then coalesce(usr.FirstName + ' '+ usr.LastName,'') else '' end) bdmName, 
		max(case when usr.ID = coalesce(job.BroughtBy,job.createdby) then coalesce(usr.ProfilePhoto,'') else '' end) bdmPhoto,
		max(case when usr.ID = jobCand.recruiterID then coalesce(usr.FirstName + ' '+ usr.LastName,'') else '' end) recrName, 
		max(case when usr.ID = jobCand.recruiterID then coalesce(usr.ProfilePhoto,'') else '' end) recrPhoto,
		intrvw.InterviewDate, coalesce(job.BroughtBy,job.createdby) bdmId, jobCand.recruiterID,
		(case candStatus.CSCode when 'CL1' then 1 when 'CRD' then 2 else 3 end) tabNo
	from 
		[dbo].[PH_JOB_CANDIDATE_INTERVIEWS] intrvw with (nolock)
		inner join [dbo].[PH_JOB_OPENINGS] job with (nolock) on job.ID=intrvw.JOID and intrvw.Status=1 and job.Status=1 
		and intrvw.InterviewerEmail is not null and len(intrvw.InterviewerEmail)>0 and job.JobOpeningStatus not in (select ID from [dbo].[PH_JOB_STATUS_S] where jscode in ('CLS'))
		inner join [dbo].[PH_CANDIDATE_PROFILES] cand with (nolock) on cand.ID=intrvw.CandProfID and cand.Status=1
		inner join [dbo].[PH_JOB_CANDIDATEs] jobCand with (nolock) on job.ID=jobCand.JOID and cand.ID=jobCand.CandProfID
		inner join [dbo].[PH_CAND_STATUS_S] candStatus with (nolock) on jobCand.CandProfStatus= candStatus.ID and candStatus.CSCode in ('CL1', 'CRD', 'CHD', 'OHD')
		inner join [dbo].[PI_HIRE_USERS] usr with (nolock) on (usr.ID = jobCand.recruiterID or usr.ID = coalesce(job.BroughtBy,job.createdby))
	 
	group by intrvw.ID,
			intrvw.JOID,intrvw.CandProfID,
			intrvw.InterviewStatus,intrvw.ModeOfInterview,intrvw.InterviewStartTime,intrvw.InterviewEndTime, 
			job.ClientID, job.ClientName, job.JobTitle, job.ReopenedDate,
			cand.CandName, cand.EmailID, cand.ContactNo,
			intrvw.InterviewDate, coalesce(job.BroughtBy,job.createdby), jobCand.recruiterID,
			candStatus.CSCode
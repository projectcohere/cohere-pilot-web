import { IFileView, IUpload } from "./Files"

// -- types --
interface UploadFilesRequest {
  authenticityToken: string
  chatId: string | null
  files: IFileView[]
}

interface UploadFilesResponse {
  data: {
    fileIds: number[]
  }
}

// -- impls --
export async function UploadFiles(req: UploadFilesRequest): Promise<number[]> {
  // find files to upload
  const uploads: IUpload[] = []
  for (const file of req.files) {
    if ("file" in file) {
      uploads.push(file)
    }
  }

  // nothing to upload, return whatever ids we have
  if (uploads.length === 0) {
    req.files.map((a) => a.id)
  }

  // otherwise, construct form body from uploads
  const body = new FormData()
  body.set("authenticity-token", req.authenticityToken)

  let index = 0
  for (const upload of uploads) {
    body.append(`files[${index++}]`, upload.file)
  }

  // post the request
  let endpoint = "/chat/files"
  if (req.chatId != null) {
    endpoint = `/chats/${req.chatId}/files`
  }

  const response = await window.fetch(endpoint, {
    method: "POST",
    body
  })

  // extract file ids from response
  const json: UploadFilesResponse = await response.json()
  const fileIds = json.data.fileIds

  // return all ids
  const ids = []

  let i = 0
  for (const file of req.files) {
    if ("file" in file) {
      ids.push(fileIds[i++])
    } else {
      ids.push(file.id)
    }
  }

  return ids
}

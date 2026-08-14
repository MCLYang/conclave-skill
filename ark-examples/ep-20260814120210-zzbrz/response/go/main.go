// Install:
// go get -u github.com/volcengine/volcengine-go-sdk

package main

import (
	"context"
	"fmt"
	"os"

	"github.com/samber/lo"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime/model/responses"
)

func main() {
	client := arkruntime.NewClientWithApiKey(
		//通过 os.Getenv 从环境变量中获取 ARK_API_KEY
		os.Getenv("ARK_API_KEY"),
		arkruntime.WithBaseUrl("https://ark.cn-beijing.volces.com/api/v3"),
	)
	// 创建一个上下文，通常用于传递请求的上下文信息，如超时、取消等
	ctx := context.Background()

	inputMessage := &responses.ItemInputMessage{
		Role: responses.MessageRole_user,
		Content: []*responses.ContentItem{
			{
				Union: &responses.ContentItem_Image{
					Image: &responses.ContentItemImage{
						Type:     responses.ContentItemType_input_image,
						ImageUrl: lo.ToPtr("https://ark-project.tos-cn-beijing.volces.com/doc_image/ark_demo_img_1.png"),
					},
				},
			},
			{
				Union: &responses.ContentItem_Text{
					Text: &responses.ContentItemText{
						Type: responses.ContentItemType_input_text,
						Text: "你看见了什么？",
					},
				},
			},
		},
	}

	resp, err := client.CreateResponses(ctx, &responses.ResponsesRequest{
		Model: "ep-20260814120210-zzbrz",
		Input: &responses.ResponsesInput{
			Union: &responses.ResponsesInput_ListValue{
				ListValue: &responses.InputItemList{ListValue: []*responses.InputItem{{
					Union: &responses.InputItem_InputMessage{
						InputMessage: inputMessage,
					},
				}}},
			},
		},
	})
	if err != nil {
		fmt.Printf("response error: %v\\n", err)
		return
	}
	fmt.Println(resp)
}
